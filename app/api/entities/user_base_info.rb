module Entities
  class UserBaseInfo < Base
    expose :id, documentation: {type: 'integer', desc: '用户id', required: true}
    expose :name, documentation: {type: 'string', desc: '用户姓名', required: true}
    expose :email, documentation: {type: 'string', desc: '邮箱', required: true}
  end
end