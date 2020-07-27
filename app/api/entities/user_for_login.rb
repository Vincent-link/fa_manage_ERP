module Entities
  class UserForLogin < UserWithAvatar
    expose :proxier_id, documentation: {type: 'string', desc: '代理用户id', required: true}
  end
end