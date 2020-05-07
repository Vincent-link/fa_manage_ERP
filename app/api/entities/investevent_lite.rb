module Entities
  class InvesteventLite < Base
    expose :id, documentation: {type: 'integer', desc: '案例id', required: true}
    expose :company_name, as: :name, documentation: {type: 'string', desc: '案例名称', required: true}
    expose :invest_round_id, documentation: {type: 'string', desc: '轮次id', required: true}
    expose :invest_type_id, documentation: {type: 'string', desc: '融资类型id', required: true}
    expose :birth_date, as: :date, documentation: {type: 'date', desc: '案例时间', required: true}
    expose :company_id, documentation: {type: 'integer', desc: '公司id'}
  end
end