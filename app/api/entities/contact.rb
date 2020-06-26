module Entities
  class Contact < Base
    expose :id, documentation: {type: 'integer', desc: 'id'}
    expose :name, documentation: {type: 'string', desc: '姓名'}
    expose :position, documentation: {type: 'Integer', desc: '职位'}
    expose :tel, documentation: {type: 'string', desc: '电话'}
    expose :wechat, documentation: {type: 'string', desc: '微信'}
    expose :email, documentation: {type: 'string', desc: 'email'}
  end
end
