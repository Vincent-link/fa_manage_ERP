module Entities
  class InvestmentEventLite < Base
    expose :id, documentation: {type: 'integer', desc: '案例id', required: true}
    expose :name, documentation: {type: 'string', desc: '案例名称', required: true}
    expose :date, documentation: {type: 'date', desc: '案例时间', required: true}
  end
end