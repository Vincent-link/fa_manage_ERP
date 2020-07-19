module Entities
  class UserCoverInvestor < Base
    expose :id, documentation: {type: 'integer', desc: 'id'}
    expose :member, using: Entities::MemberLite, documentation: {type: 'string', desc: '投资人'}
  end
end
