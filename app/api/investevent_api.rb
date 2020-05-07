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

    def stat_next_round(events)
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
    resource configuration[:owner] do
      resource ':id' do
        resource :events do
          desc '统计图表'
          params do
            optional :start_time, type: String, desc: '起始时间'
            optional :end_time, type: String, desc: '结束时间'
            optional :select, type: Array[String], desc: '图表数据白名单 sector/round/time/location/next_round/last_round 不传返回所有'
          end
          desc '行业统计'
          get 'stat' do
            organization = Organization.find(params[:id])
            events = organization.dm_investevent #todo date_filter

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
              }
            end
          end
        end
      end
    end
  end

  resource :investevents do
    desc '案例列表', entity: Entities::InvesteventForIndex
    params do
      optional :organization_id, as: :investor_id, type: Integer, desc: '机构id'
      optional :member_id, type: Integer, desc: '投资人id'
      at_least_one_of :organization_id, :member_id
      requires :page, type: Integer, desc: '页数', default: 1
      requires :per_page, type: Integer, desc: '每页数', default: 30
    end
    get do
      #todo member
      if params[:member_id]
        events = Zombie::DmInvestevent.by_member(params[:member_id]).order_by_date.paginate(page: params[:page], per_page: params[:per_page])
      else
        events = Zombie::DmInvestevent.by_investor(params[:organization_id]).order_by_date.paginate(page: params[:page], per_page: params[:per_page])
      end

      present events.inspect, with: Entities::InvesteventForIndex
    end
  end
end