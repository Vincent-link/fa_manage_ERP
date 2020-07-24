module ModelStatistic
  module PipelineStatistic
    extend ActiveSupport::Concern

    TAX_RATE = 1.06

    class_methods do
      # 合计
      def amount_to(pipelines_list)
        %i[count est_amount_sum total_fee_sum this_year_total_fee_sum complete_rate rate_total_fee_sum time_weight_rate time_weight_income_sum].inject({}) do |res, item|
          res.merge!({:"#{item}" => pipelines_list.sum { |p| p[item] }})
        end
      end

      # 税后
      def after_tax(amount_to)
        %i[count est_amount_sum total_fee_sum this_year_total_fee_sum complete_rate rate_total_fee_sum time_weight_rate time_weight_income_sum].inject({}) do |res, item|
          value = %i[total_fee_sum this_year_total_fee_sum rate_total_fee time_weight_income_sum].include?(item) ?  (amount_to[item] / TAX_RATE).round(2) : nil
          res.merge!({:"#{item}" => value})
        end
      end

      # 融资详情币种不同，未填写成功费时返回的信息
      # 后端只需判断total_fee是否为0
      # TODO:返回数据结构未确定
      def sny_message(pipelines)
        return {} if pipelines.blank?
        if (ps = pipelines.select { |pipeline| pipeline[:total_fee].zero? }).present?
          {
            fundings: { ids: ps.pluck(:funding_id), names: ps.pluck(:name) },
            pipelines: { ids: ps.pluck(:id) }
          }
        else
          {}
        end
      end

      # pipeline 概览返回的数据
      def options_for_pipelines(pipelines)
        {
          count: pipelines.size,
          est_amount_sum: pipelines.sum { |p| p[:est_amount_rmb] },
          total_fee_sum: pipelines.sum { |p| p[:total_fee_rmb] },
          this_year_total_fee_sum: pipelines.sum { |p| p[:this_year_total_fee_rmb] },
          complete_rate: Common::Numeric.divide(pipelines.sum { |p| p[:complete_rate] }, pipelines.size),
          rate_total_fee_sum: pipelines.sum { |p| p[:rate_total_fee_rmb] },
          time_weight_rate: Common::Numeric.divide(pipelines.sum{ |p| p[:time_weight_rate] }, pipelines.size),
          time_weight_income_sum: pipelines.sum { |p| p[:time_weight_income_rmb] },
          sny_message: sny_message(pipelines)
        }
      end

      # pipeline 概览
      def group_by_status_type(options = {})
        pipelines = es_search(options)[:results]
        result = %i[without_ts closing completed].inject([]) do |res, item|
          res << { :"#{item}" => pipelines.select { |p| p[:status].in?(status_type_values(item)) } }
        end.map do |_res|
          list = _res.values.flatten.group_by { |p| p[:status] }.map do |status, ps|
            options_for_pipelines(ps).merge(status: status_desc_for_value(status))
          end
          # 合计
          total = {status: '合计'}.merge(amount_to(list))
          # 税后
          after_tax = {status: '税后'}.merge(after_tax(total))

          { type: _res.keys.first.to_s, pipelines: list + [total] + [after_tax] }
        end

        # 完成&执行总计
        unpass_pipelines = pipelines.select { |p| !p[:status].in?(status_type_values(:pass)) }
        # 合计
        unpass_pipelines_total = options_for_pipelines(unpass_pipelines).merge(
          complete_rate: Common::Numeric.divide(unpass_pipelines.sum { |p| Common::Numeric.divide(p[:rate_total_fee_rmb], p[:total_fee_rmb]) }, unpass_pipelines.size),
          time_weight_rate: Common::Numeric.divide(unpass_pipelines.sum { |p| Common::Numeric.divide(p[:time_weight_income_rmb], p[:total_fee_rmb]) }, unpass_pipelines.size),
          status: '合计')

        # 税后
        unpass_after_tax = {status: '税后'}.merge(after_tax(unpass_pipelines_total))
        unpass_result = [ {type: 'unpass', pipelines: [unpass_pipelines_total] + [unpass_after_tax]} ]

        result + unpass_result
      end

      # 分组概览返回的数据
      def options_for_team_statistic(pipelines)
        {
          count: pipelines.size,
          est_amount_sum: pipelines.sum { |p| p[:est_amount_rmb] },
          total_fee_sum: pipelines.sum { |p| p[:total_fee_rmb] },
          rate_total_fee_sum: pipelines.sum { |p| p[:rate_total_fee_rmb] },
          time_weight_income_sum: pipelines.sum { |p| p[:time_weight_income_rmb] },
          execution_day_avg: Common::Numeric.divide(pipelines.sum { |p| p[:execution_day] }, pipelines.size).round,
          sny_message: sny_message(pipelines)
        }
      end

      # 555为重复的市场组(326), 573: 沈莹珠(离职)
      def statistic_teams_hash
        team_ids = [565, 566, 570, 571, 572, 574, 567, 568, 569, 575, 576, 577, 553, 549, 326]
        # team_ids = User.where(bu_id: 244).pluck(:team_id).uniq - [244, 573, 555]
        Team.select(:id, :name).where(id: team_ids).inject({}) do |res, item|
          res.merge!({item.id => item.name})
        end
      end

      # pipeline 分组统计
      def group_by_team(options = {})
        statistic_status = status_type_values(:without_ts) + status_type_values(:complete)
        pipelines = es_search(options)[:results]

        statistic_teams_hash.keys.inject([]) do |res, team_id|
          team_pipelines = pipelines.select { |p| p[:funding_user_team_ids].include?(team_id) }.uniq
          list = statistic_status.inject([]) do |res_, status|
            status_pipelines = team_pipelines.select { |p| p[:status] == status }
            res_ << options_for_team_statistic(status_pipelines).merge(status_desc: status_desc_for_value(status), status: status)
          end

          res << { name: statistic_teams_hash[team_id], pipelines: list }
        end
      end

      # 饼图
      def statistic_pie_for_bu(options = {})
        statistic_status_hash = %i[completed closing without_ts].inject({}) do |result, item|
          result.merge!({item => status_type_values(item)})
        end.merge(unpass: unpass_status_values)
        pipelines = es_search(options)[:results]
        teams_hash = statistic_teams_hash

        statistic_status_hash.keys.inject([]) do |res, item|
          status_values = statistic_status_hash[item]
          status_pipelines = pipelines.select { |p| p[:status].in?(status_values) }

          team_pipelines_hash = teams_hash.keys.inject({}) do |res_, team_id|
            team_pipelines = status_pipelines.select { |p| p[:funding_user_team_ids].include?(team_id) }.uniq
            res_.merge!(team_id => team_pipelines)
          end

          data = %w[rate_total_fee this_year_total_fee].inject([]) do |data_res, attr|
            attr_array = teams_hash.keys.inject([]) do |team_res, team_id|
              team_pipelines = team_pipelines_hash[team_id]
              team_res << { value: team_pipelines.sum { |t_p| t_p["#{attr}_rmb".to_sym] },  name: teams_hash[team_id]}
            end

            data_res << { name: attr, data: attr_array }
          end

          res << { status: item.to_s, data: data}
        end
      end

      # 按时间维度统计
      def statistic_by_est_bill_date(options = {})
        pipelines = es_search(options.merge(need_est_bill_date: true))[:results]
        pipelines_by_status = pipelines.group_by { |p| p[:status] }
        date = convert_date(options[:year], options[:month])
        this_year_pipelines = pipelines.select { |p| p[:est_bill_date] <= date.to_s }
        next_year_pipelines = pipelines - this_year_pipelines
        this_year_pipelines_by_status = this_year_pipelines.group_by { |p| p[:status] }
        this_year_pipelines_by_month = this_year_pipelines.group_by { |p| p[:est_bill_date].to_date.month }
        next_year_pipelines_status = next_year_pipelines.group_by { |p| p[:status] }

        # 项目数量
        funding_count = (1..12).inject([]) do |arr, i|
          arr << (this_year_pipelines_by_month[i] || []).pluck(:funding_id).uniq.size
        end << next_year_pipelines.pluck(:funding_id).uniq.size

        # 不同状态
        status_total_fee_sum = status_values.inject({}) do |res, value|
          status_month_count = (1..12).inject([]) do |arr, i|
            arr << (this_year_pipelines_by_status[value] || []).select { |p| p[:est_bill_date].to_date.month == i }.sum { |p| p[:total_fee_rmb] }
          end << (next_year_pipelines_status[value] || []).sum { |p| p[:total_fee_rmb] }

          res.merge!({ value => { data: status_month_count, sny_message: sny_message(pipelines_by_status[value]) } })
        end

        # 每月预测
        month_forecast = (1..12).inject([]) do |res, i|
          res << (this_year_pipelines_by_month[i] || []).sum { |p| p[:total_fee_rmb] }
        end << next_year_pipelines.sum { |p| p[:total_fee_rmb] }

        # 每月概率
        month_rate = (1..12).inject([]) do |res, i|
          res << (this_year_pipelines_by_month[i] || []).sum { |p| p[:rate_total_fee_rmb] }
        end << next_year_pipelines.sum { |p| p[:rate_total_fee_rmb] }

        # 每月加权概率
        month_weight_rate = (1..12).inject([]) do |res, i|
          res << (this_year_pipelines_by_month[i] || []).sum { |p| p[:time_weight_income_rmb] }
        end << next_year_pipelines.sum { |p| p[:time_weight_income_rmb] }

        # 季度节点预测
        quarter_forecast = []
        month_forecast[0..-2].each_slice(3) { |arr| quarter_forecast += [ nil, nil, arr.sum] }

        # 季度节点概率
        quarter_rate = []
        month_rate[0..-2].each_slice(3) { |arr| quarter_rate += [ nil, nil, arr.sum]}

        # 季度加权概率
        quarter_weight_rate = []
        month_weight_rate[0..-2].each_slice(3) { |arr| quarter_weight_rate += [ nil, nil, arr.sum] }

        # 季度税后预测
        after_tax_quarter_forecast = quarter_forecast.map { |i| i / TAX_RATE unless i.nil? }

        # 季度税后预测
        after_tax_quarter_rate = quarter_rate.map { |i| i / TAX_RATE  unless i.nil? }

        # 预算Better(税后)
        quarter_better = [nil, nil, Settings.pipeline.first_quarter_better, nil, nil, Settings.pipeline.second_quarter_better, nil, nil, Settings.pipeline.third_quarter_better, nil, nil, Settings.pipeline.fourth_quarter_better]

        # 预算Bear(税后)
        quarter_bear = [nil, nil, Settings.pipeline.first_quarter_bear, nil, nil, Settings.pipeline.second_quarter_bear, nil, nil, Settings.pipeline.third_quarter_bear, nil, nil, Settings.pipeline.fourth_quarter_bear]

        {
          funding_numbers: funding_count,
          status_total_fee_sum: status_total_fee_sum,
          month_forecast: month_forecast,
          month_rate: month_rate,
          month_weight_rate: month_weight_rate,
          quarter_forecast: quarter_forecast,
          quarter_rate: quarter_rate,
          quarter_weight_rate: quarter_weight_rate,
          after_tax_quarter_forecast: after_tax_quarter_forecast,
          after_tax_quarter_rate: after_tax_quarter_rate,
          quarter_better: quarter_better,
          quarter_bear: quarter_bear
        }
      end
    end
  end
end
