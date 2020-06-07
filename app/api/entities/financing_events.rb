module Entities
  class FinancingEvents < Base
    # expose :company_id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :created_at, documentation: {type: 'string', desc: '创建时间', required: true}
    expose :invest_type_and_batch_desc, documentation: {type: 'string', desc: '', required: true}
    expose :status, documentation: {type: 'string', desc: '', required: true}
  end
end
