module Entities
  class FundingFinancingEvent < Base
    expose :is_event, documentation: {type: 'boolean', desc: '是否是融资事件'}
    expose :round_id, documentation: {type: 'integer', desc: '轮次'}
    expose :event_data, with: Entities::FundingEventData, documentation: {type: Entities::FundingEventData, desc: '列表数据'}
  end
end