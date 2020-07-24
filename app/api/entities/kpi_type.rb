module Entities
  class KpiType < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: '名称', required: true}
    expose :unit, documentation: {type: 'string', desc: '单位', required: true}
    expose :remarks, documentation: {type: 'string', desc: '描述', required: true}
  end
end
