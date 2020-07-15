module Entities
  class FundingGroupWithStatus < Base
    expose :status, documentation: {type: 'integer', desc: '状态'}
    expose :data, with: Entities::FundingLite, documentation: {type: Entities::FundingLite, desc: '数据'}
  end
end