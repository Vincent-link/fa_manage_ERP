module Entities
  class UserForLogin < Base
    expose :id, documentation: {type: 'integer', desc: '用户id', required: true}
    expose :name, documentation: {type: 'string', desc: '用户姓名', required: true}
    expose :avatar, documentation: {type: 'string', desc: '用户头像', required: true}
    expose :proxier_id, documentation: {type: 'string', desc: '代理用户id', required: true}
  end
end