module Entities
  class Payment < Base
    expose :id, documentation: {type: 'integer', desc: 'id'}

    expose :pipeline_id, documentation: {type: 'integer', desc: 'pipeline_id'}
    expose :amount, documentation: {type: 'integer', desc: '金额'}
    expose :currency, documentation: {type: 'integer', desc: '币种'}
    expose :pay_date, documentation: {type: 'date', desc: '付款日期'}
  end
end