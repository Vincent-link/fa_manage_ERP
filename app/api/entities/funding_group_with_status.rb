module Entities
  class FundingGroupWithStatus < Base
    expose :status, documentation: {type: 'Entities::IdName', desc: '状态'} do |ins|
      {
          id: ins[:status],
          name: 'Funding'.constantize.status_desc_for_value(ins[:status])
      }
    end
    expose :data, with: Entities::FundingBaseInfo, documentation: {type: Entities::FundingBaseInfo, desc: '数据'}
  end
end