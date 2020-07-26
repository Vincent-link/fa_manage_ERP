module ModelSearch
  module PipelineSearch
    extend ActiveSupport::Concern

    class_methods do
      def pipeline_search_where(options = {})
        where_hash = options.slice(:funding_status, :est_amount_currency, :is_list_company, :funding_source, :status).symbolize_keys
        if options[:is_round].to_s == 'true'
          where_hash[:funding_round_id] = options[:funding_category]
        elsif options[:is_round].to_s == 'false'
          where_hash[:funding_category] = options[:funding_category]
        end

        where_hash[:company_sector_ids] = options[:sector_id] if options[:sector_id].present?
        where_hash[:funding_user_team_ids] = options[:team_id] if options[:team_id].present?
        where_hash[:funding_name] = { like: "%#{options[:funding_name]}%" } if options[:funding_name].present?
        where_hash[:user_id] = User.current&.id if options[:is_me]

        # 处理status
        status_array = convert_status(options)

        # 处理年份和月份
        end_of_month_day = convert_date(options[:year], options[:month])
        end_of_month_datetime = end_of_month_day.end_of_day
        beginning_of_month_day = end_of_month_day.beginning_of_month

        if status_array.include?(status_fee_ed_value) && (other_status = status_array - [status_fee_ed_value]).present?
          where_hash[:_or] = [{ status: other_status, updated_at:  { lte: end_of_month_datetime } }, { status: status_fee_ed_value, operating_day: { gte: beginning_of_month_day, lte: end_of_month_day }, updated_at:  { lte: end_of_month_datetime }}]
        else
          where_hash[:status] = status_array
          where_hash[:updated_at] = { lte: end_of_month_datetime }
          where_hash[:operating_day] = { gte: beginning_of_month_day, lte: end_of_month_day } if status_array == [status_fee_ed_value]
        end

        if options[:need_est_bill_date]
          where_hash[:est_bill_date] = { gte: end_of_month_day.beginning_of_year, lte: end_of_month_day.next_year.end_of_year }
          where_hash[:_not] = { est_bill_date: { gt: end_of_month_day, lte: end_of_month_day.end_of_year } }
        end

        where_hash
      end

      def search_order(options = {})
        order_hash = { updated_at: :desc }

        if (sort = options[:sort] ).present?
          order = case sort
                  when 1
                    'updated_at'
                  when 2
                    'el_date'
                  when 3
                    'est_bill_date'
                  when 4
                    'execution_day'
                  when 5
                    'total_fee'
                  when 6
                    'bu_rate'
                  when 7
                    'bu_total_fee_rmb'
                  when 8
                    'complete_rate'
                  when 9
                    'bu_rate_income_rmb'
                  when 10
                    'funding_operating_day'
                  end

          by = if sort == 1
                 (options[:by] == 2) ? 'asc' : 'desc'
               else
                 (options[:by] == 2) ? 'desc' : 'asc'
               end

          order_hash = {"#{order}" => by}
        end
        order_hash
      end

      def convert_status(options = {})
        status_type_values = case options[:type]
                             when 1
                               unpass_status_values
                             when 2
                               status_type_values(:completed)
                             when 3
                               status_type_values(:closing)
                             when 4
                               status_type_values(:without_ts)
                             when 5
                               status_type_values(:pass)
                             end

        status = options[:status]
        if status_type_values.present? && status.blank?
          status_type_values
        elsif status_type_values.present? && status.present?
          status_type_values & [status]
        elsif status_type_values.blank? && status.present?
          [status]
        else
         status_values
        end
      end

      def convert_date(year = nil, month = nil)
        # 处理年份和月份
        year = year.present? && year <= Date.today.year ? year : Date.today.year
        month = if month.present?
                  Date.new(year, month) <= Date.today ? month : Date.today.month
                else
                  year >= Date.today.year ? Date.today.month : Date.new(year).end_of_year.month
                end

        Date.new(year, month).end_of_month
      end

      def version_pipeline_search_where(options = {})
        # 处理status
        status_array = convert_status(options)

        # 处理年份和月份
        end_of_month_day = convert_date(options[:year], options[:month])
        end_of_month_datetime = end_of_month_day.end_of_day
        beginning_of_month_day = end_of_month_day.beginning_of_month

        where_hash = {}
        where_hash['version_pipeline.date'] = end_of_month_day
        where_hash['version_pipeline.funding_status'] = options[:funding_status] if options[:funding_status].present?
        where_hash['version_pipeline.est_amount_currency'] = options[:est_amount_currency] if options[:est_amount_currency].present?
        where_hash['version_pipeline.is_list_company'] = options[:is_list_company] if options[:is_list_company].present?
        where_hash['version_pipeline.funding_source'] = options[:funding_source] if options[:funding_source].present?
        where_hash['version_pipeline.funding_user_team_ids'] = options[:team_id] if options[:team_id].present?

        if options[:is_round].to_s == 'true'
          where_hash['version_pipeline.funding_round_id'] = options[:funding_category]
        elsif options[:is_round].to_s == 'false'
          where_hash['version_pipeline.funding_category'] = options[:funding_category]
        end

        if status_array.include?(status_fee_ed_value) && (other_status = status_array - [status_fee_ed_value]).present?
          where_hash[:_or] = [{ 'version_pipeline.status' => other_status, 'version_pipeline.updated_at' =>  { lte: end_of_month_datetime } }, {'version_pipeline.status' => status_fee_ed_value, 'version_pipeline.operating_day' => { gte: beginning_of_month_day, lte: end_of_month_day }, 'version_pipeline.updated_at' =>  { lte: end_of_month_datetime }}]
        else
          where_hash['version_pipeline.status'] = status_array
          where_hash['version_pipeline.updated_at'] = { lte: end_of_month_datetime }
          where_hash['version_pipeline.operating_day'] = { gte: beginning_of_month_day, lte: end_of_month_day } if status_array == [status_fee_ed_value]
        end

        if options[:need_est_bill_date]
          where_hash['version_pipeline.est_bill_date'] = { gte: end_of_month_day.beginning_of_year, lte: end_of_month_day.next_year.end_of_year }
          where_hash[:_not] = { 'version_pipeline.est_bill_date' => { gt: end_of_month_day, lte: end_of_month_day.end_of_year } }
        end

        where_hash.symbolize_keys
      end

      def es_search(options = {})
        if (date = convert_date(options[:year], options[:month])) >= Date.current.end_of_month
          results = search(where: pipeline_search_where(options), order: search_order(options), page: options[:page], per_page: options[:per_page], load: false)
          { results: results.hits.map { |hit| hit['_source'].except('version_pipeline') }.map(&:symbolize_keys), page_info: { per_page: results.per_page, total_entries: results.total_entries, total_pages: results.total_pages, current_page: results.current_page } }
        else
          results = search(where: version_pipeline_search_where(options), order: search_order(options), page: options[:page], per_page: options[:per_page], load: false)
          { results: results.hits.flat_map { |hit| hit['_source']['version_pipeline'].select { |p| p['date'] == date.to_s } }.map(&:symbolize_keys), page_info: { per_page: results.per_page, total_entries: results.total_entries, total_pages: results.total_pages, current_page: results.current_page } }
        end
      end
    end
  end
end
