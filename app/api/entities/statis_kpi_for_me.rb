module Entities
  class StatisKpiForMe < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :kpi_type, documentation: {type: 'integer', desc: 'kpi类型', required: true}
    expose :desc, documentation: {type: 'string', desc: '描述', required: true}
    expose :kpi_statis_value, documentation: {type: 'integer', desc: 'kpi统计值', required: true} do |ins, options|
      ins.statis_my_kpi(options[:user_id], options[:year])
    end
    expose :value, documentation: {type: 'integer', desc: 'kpi配置值', required: true}
    expose :is_in_system, documentation: {type: 'integer', desc: '是否在系统中统计', required: true} do |ins, options|
      ins.is_in_system
    end
    expose :relation, documentation: {type: 'StatisKpiForMe', desc: '关系', required: true}
    expose :conditions, documentation: {type: 'StatisKpiForMe', desc: '条件', required: true}, using: Entities::StatisKpiForMe
  end
end
