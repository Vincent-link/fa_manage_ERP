module Entities
  class KpiType < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'integer', desc: '名称', required: true}
  end
end
