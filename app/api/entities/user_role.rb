module Entities
  class UserRole < Base
    expose :id, documentation: {type: 'integer', desc: '用户id', required: true}
    expose :user_id, documentation: {type: 'integer', desc: '用户id', required: true}
    expose :role_id, documentation: {type: 'integer', desc: '角色id', required: true}
  end
end