module Entities
  class Kpi < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :kpi_type, documentation: {type: 'integer', desc: '类型', required: true}
    expose :coverage, documentation: {type: 'integer', desc: '范围', required: true}
    expose :value, documentation: {type: 'integer', desc: '值', required: true}
    expose :desc, documentation: {type: 'string', desc: '描述', required: true}
    expose :conditions, using: Entities::Kpi
  end
end
