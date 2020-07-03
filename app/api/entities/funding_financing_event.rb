module Entities
  class FundingFinancingEvent < Base
    expose :is_event, documentation: {type: 'boolean', desc: '是否是融资事件'}
    expose :round_id, documentation: {type: 'integer', desc: '轮次'}
    expose :target_amount, documentation: {type: 'integer', desc: '投资金额'}
    expose :target_amount_currency, documentation: {type: 'integer', desc: '投资金额币种'}
    expose :event_data, with: Entities::FundingEventData, documentation: {type: Entities::FundingEventData, desc: '列表数据'}
  end
end