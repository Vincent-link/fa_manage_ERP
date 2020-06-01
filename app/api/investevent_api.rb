class InvesteventApi < Grape::API

  helpers do
    def stat_sector(events)
      hash = events.group_by(&:company_category_id)
      hash.transform_values! {|v| v.size}
      hash.map {|k, v| {name: k, value: v}}
    end

    def stat_round(events)
      hash = events.group_by(&:invest_round_id)
      hash.transform_values! {|v| v.size}
      hash.map {|k, v| {name: k, value: v}}
    end

    def stat_time(events)
      hash = events.group_by {|ins| ins.birth_date && ins.birth_date[0..3]}
      hash.transform_values! {|v| v.size}
      hash.map {|k, v| {name: k, value: v}}
    end

    def stat_location(events)
      hash = events.group_by(&:company_location_province_id)
      hash.transform_values! {|v| v.size}
      hash.map {|k, v| {name: k, value: v}}
    end

    def stat_role(events)
      hash = events.group_by {|e| e.investevent_investor_rels&.first&.lead_type}.compact
      hash.transform_values! {|v| v.size}
      hash.transform_keys! {|k| k == 1 ? '领投' : '跟投'}
      hash.map {|k, v| {name: k, value: v}}
    end

    def stat_next_round(events)
      #todo 假数据
      [{
           name: '是',
           value: 123
       }, {
           name: '否',
           value: 223
       }]
    end

    def stat_last_round(events)
      hash = events.group_by(&:company_id)
      hash.transform_values! {|v| v.sort_by(&:birth_date).last}
      events = hash.values.flatten
      hash = events.group_by(&:invest_round_id)
      hash.transform_values! {|v| v.size}
      hash.map {|k, v| {name: k, value: v}}
    end
  end

  mounted do
    if configuration[:owner]
      resource configuration[:owner] do
        resource ':id' do
          resource :events do
            desc '统计图表'
            params do
              optional :start_time, type: String, desc: '起始时间'
              optional :end_time, type: String, desc: '结束时间'
              optional :select, type: Array[String], desc: '图表数据白名单 sector/round/time/location/next_round/last_round 不传返回所有'
            end
            get 'stat' do
              events = Zombie::DmInvestevent.includes(:investevent_investor_relations).where(investevent_investor_relations: {investor_id: params[:id]})._select(:id, :birth_date, :company_category_id, :invest_round_id, :company_location_province_id, :lead_type, :investevent_investor_rels)

              if params[:start_time] || params[:end_time]
                params[:start_time] ||= '1970-01-01'
                params[:end_time] ||= '2099-01-01'
                events = events.by_birth_date_range(params[:start_time], params[:end_time])
              end

              if params[:select].present?
                res = {}
                params[:select].each {|select| res[select] = send("stat_#{select}", events)}
                res
              else
                {
                    sector: stat_sector(events),
                    round: stat_round(events),
                    time: stat_time(events),
                    next_round: stat_next_round(events),
                    last_round: stat_last_round(events),
                    location: stat_location(events),
                    role: stat_role(events),
                }
              end
            end
          end
        end
      end
    end
  end

  resource :investevents do
    desc '案例列表', entity: Entities::InvesteventForIndex
    params do
      optional :organization_id, type: Integer, desc: '机构id'
      optional :member_id, type: Integer, desc: '投资人id'
      at_least_one_of :organization_id, :member_id
      optional :sectors, type: Array[Integer], desc: '行业'
      optional :rounds, type: Array[Integer], desc: '轮次'
      optional :start_date, type: String, desc: '案例起始时间'
      optional :end_date, type: String, desc: '案例结束时间'
      requires :page, type: Integer, desc: '页数', default: 1
      requires :page_size, as: :per_page, type: Integer, desc: '每页数', default: 30
    end
    get do
      events = if params[:start_date] || params[:end_date]
                 Zombie::DmInvestevent.by_birth_date_range(params[:start_date] || '1000-01-01', params[:end_date] || '3000-01-01')
               else
                 Zombie::DmInvestevent
               end
      events = events.search(sector: params[:sectors]) if params[:sectors]
      events = events.search(round: params[:rounds]) if params[:rounds]
      if params[:member_id]
        events = events.by_member(params[:member_id]).order_by_date._select(:id, :birth_date, :company_name, :company_category_id, :invest_round_id, :company_location_province_id, :lead_type, :investevent_investors, :invest_type_id, :company_id, :detail_money_des, :overview).paginate(page: params[:page], per_page: params[:per_page])
      else
        events = events.by_investor(params[:organization_id]).order_by_date._select(:id, :birth_date, :company_name, :company_category_id, :invest_round_id, :company_location_province_id, :lead_type, :investevent_investors, :invest_type_id, :company_id, :detail_money_des, :overview).paginate(page: params[:page], per_page: params[:per_page])
      end

      present events.inspect, with: Entities::InvesteventForIndex
    end
  end
end