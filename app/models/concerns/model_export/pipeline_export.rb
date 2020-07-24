module ModelExport
  module PipelineExport
    extend ActiveSupport::Concern

    class_methods do
      def export_for_pipeline_list(options = {})
        date = convert_date(options[:year], options[:month])
        pipelines = es_search(options)[:results]
        file_name = "Pipeline_On_#{date.to_s(:month)}"
        file_path = "#{Rails.root}/public/export/#{file_name}-#{Time.now.to_s(:second)}.xls"

        first_pre_row = %w[项目名称 项目状态 Pipeline阶段 上次更新 产品 FA负责小组 所属行业 是否为上市公司 签EL/启动日期]
        values = %i(funding_name funding_status_desc status_desc last_updated_day name funding_member_teams company_sectors is_list_company el_date)
        if options[:type] == 5
          res = [first_pre_row + %w(进入Hold日期 执行天数 币种 总交易规模 本BU分成比例 来源部门)]
          values += %i(funding_operating_day execution_day est_amount_currency_desc est_amount bu_rate funding_funding_source_desc)
        else
          res = [first_pre_row + %w(预计开账单日期 执行天数 币种 总交易规模 项目总收费(RMB) 本BU分成比例 本BU收费金额(RMB) 年内收入完成概率 本BU概率收入(RMB) 来源部门)]
          values += %i(est_bill_date execution_day est_amount_currency_desc est_amount total_fee_rmb bu_rate bu_total_fee_rmb complete_rate bu_rate_income_rmb funding_funding_source_desc)
        end

        pipelines.each do |pipeline|
          res << pipeline.slice(*values).inject([]) do |result, item|
            if item.first.in?(%w(bu_rate complete_rate))
              result << item.last.to_s(:percentage, precision: 2)
            elsif item.last.is_a?(Date)
              result << item.last.to_s(:date)
            elsif item.last.is_a?(DateTime)
              result << item.last.to_s(:second)
            elsif item.last.is_a?(Array)
              result << item.last.join(', ')
            else
              result << item.last
            end
            result
          end
        end

        if options[:type] == 1
          res << [] # 空两行
          res << []
          res += statistic_by_est_bill_date_export(options)
        end

        book_data = [["sheet1", res]]
        Common::ExcelGenerator.gen(file_path, book_data)
        [file_path, file_name]
      end

      def statistic_by_est_bill_date_export(options = {})
        data = statistic_by_est_bill_date(options)
        year = options[:year].present? ? options[:year] : Date.current.year

        first_row = ["#{year}年度收入"]+ (1..12).inject([]) do |r, i|
          r << "#{year}.#{i}"
        end << "#{year + 1}年"
        res = [first_row]

        # 项目数量
        res << ['项目数量'] + data[:funding_numbers]

        # 每个状态
        status_values.each do |status|
          res <<  [status_desc_for_value(status)] + data[:status_total_fee_sum][status][:data]
        end

        # 每月预测
        res << ['每月预测'] + data[:month_forecast]
        # 每月概率
        res << ['每月概率'] + data[:month_rate]
        # 每月加权概率
        res << ['每月加权概率'] + data[:month_weight_rate]
        # 季度节点预测
        res << ['季度节点预测'] + data[:quarter_forecast]
        # 季度节点概率
        res << ['季度节点概率'] + data[:quarter_rate]
        # 季度加权概率
        res << ['季度加权概率'] + data[:quarter_weight_rate]
        # 税后预测
        res << ['税后预测'] + data[:after_tax_quarter_forecast]
        # 税后概率
        res << ['税后概率'] + data[:after_tax_quarter_rate]
        # 预算Better(税后)
        res << ['预算Better(税后)'] + data[:quarter_better]
        # 预算Bear(税后)
        res << ['预算Bear(税后)'] + data[:quarter_bear]

        res
      end

      # FA项目收入贡献表
      def fa_income_contribution_export(options = {})
        date = convert_date(options[:year], options[:month])
        fa_team_id = Settings.current_bu_id
        pipelines = es_search(options)[:results].select { |p| p[:divides].map { |d| d['bu_id']}.include?(fa_team_id) }

        file_name = "FA_Income_On_#{date.to_s(:month)}"
        file_path = "#{Rails.root}/public/export/#{file_name}-#{Time.now.to_s(:second)}.xls"
        book = ::Spreadsheet::Workbook.new

        sheet1 = book.create_worksheet(name: file_name)
        row = 0

        divides = pipelines.inject({}) { |res, p| res.merge!({p[:id] => p[:divides].select { |d| d['bu_id'] == fa_team_id } }) }
        max_divides_size = divides.present? ? divides.values.max.size : 0
        fill_nil_arr = (0...max_divides_size - 1).map { nil }

        title_row1 = %w[状态 项目名 轮次 融资币种 融资金额(原币种) 收入币种 收入(USD) 收入(RMB)]
        title_row2 = ['项目成员'] + fill_nil_arr + ['贡献比例'] + fill_nil_arr
        title_row3 = ['收入贡献'] + divides.values.flatten.sort_by { |divide| divide['user_id'] }.map { |divide| divide['user_name'] }.uniq
        title_row = title_row1 + [nil] + title_row2 + [nil] + title_row3

        yellow_format = Common::ExcelFormat.row_format(pattern: 1, pattern_fg_color: :yellow)
        green_format = Common::ExcelFormat.row_format(pattern: 1, pattern_fg_color: :green)
        default_format = Common::ExcelFormat.row_format
        first_default_format = Common::ExcelFormat.first_format

        sheet1.row(row).height = 18
        title_row.size.times do |time|
          sheet1.row(0).set_format(time, first_default_format)
        end

        sheet1.row(row).concat(title_row)

        rounds = CacheBox::dm_rounds
        pipelines.each do |pipeline|
          row += 1
          sheet1.row(row).height = 18
          sheet1.row(row).default_format = default_format
          sheet1[row, 0] = pipeline[:status_desc]
          sheet1[row, 1] = pipeline[:funding_status_desc]
          sheet1[row, 2] = rounds.find { |e| e["id"] == pipeline[:funding_round_id] }.fetch('name', nil)
          sheet1[row, 3] = Pipeline.est_amount_currency_desc_for_value(pipeline[:est_amount_currency])
          sheet1[row, 4] = pipeline[:est_amount]
          sheet1[row, 5] = pipeline[:total_fee_currency]
          sheet1[row, 6] = pipeline[:total_fee_usd]
          sheet1[row, 7] = pipeline[:total_fee_rmb]

          pipeline_divides = divides[pipeline[:id]].sort_by { |divide| divide['user_id'] }

          col = 9 # 项目成员从第9列开始
          pipeline_divides.each_with_index do |divide, index|
            col += index
            sheet1[row, col] = divide['user_name']
          end

          col += 1
          pipeline_divides.each_with_index do |divide, index|
            col += index
            sheet1[row, col] = divide['rate'].to_s(:percentage, precision: 2)
          end

          [2,3,4,5].each do |i|
            sheet1.row(row).set_format(i, yellow_format)
          end

          [6, 7].each do |i|
            sheet1.row(row).set_format(i, green_format)
          end

          (9..col).each do |i|
            sheet1.row(row).set_format(i, yellow_format)
          end
        end

        # 总计空2行
        sheet1[row + 3, 5] = 'Cash Total'
        sheet1[row + 3, 6] = pipelines.sum { |p| p[:total_fee_usd] }
        sheet1[row + 3, 7] = pipelines.sum { |p| p[:total_fee_rmb] }

        book.write(file_path)
        [file_path, file_name]
      end

      def export(options = {})
        if options[:type] == 6
          fa_income_contribution_export(options)
        else
          export_for_pipeline_list(options)
        end
      end
    end
  end
end
