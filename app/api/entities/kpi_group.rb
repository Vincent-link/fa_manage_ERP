module Entities
  class KpiGroup < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: '名称', required: true}
    expose :users, using: Entities::UserLite
    expose :kpis, using: Entities::Kpi
  end
end
