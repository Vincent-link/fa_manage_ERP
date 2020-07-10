module Entities
  class Kpi < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :kpi_type, documentation: {type: 'integer', desc: '类型', required: true}
    expose :coverage, documentation: {type: 'integer', desc: '范围', required: true}
    expose :value, documentation: {type: 'integer', desc: '值', required: true}
    expose :relation, documentation: {type: 'string', desc: '关系', required: true} 
    expose :conditions, using: Entities::Kpi
  end
end
