module Entities
  class UserForKpi < Base
    expose :id, documentation: {type: 'integer', desc: '用户id', required: true}
    expose :kpis, documentation: {type: 'string', desc: '用户姓名', required: true} do |user, options|
      arr = []
      if !user.try(:kpi_group).try(:kpis).nil?
        user.try(:kpi_group).try(:kpis).map {|kpi|
          row = {}
          user.team.users.map(&:kpi_group).compact.map(&:kpis).flatten.pluck(:kpi_type).map{|type|
            row[type] = "2/#{kpi.value}" if kpi.kpi_type == type
          }
          arr << row
        }
      end
      arr
    end
  end
end
