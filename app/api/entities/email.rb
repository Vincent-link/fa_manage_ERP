module Entities
  class Email < Base
    expose :title, documentation: {type: 'string', desc: '题目'}
    expose :greeting, documentation: {type: 'string', desc: '敬语'}
    expose :description, documentation: {type: 'string', desc: '正文'}
    expose :signature, documentation: {type: 'string', desc: '签名'}
    expose :from, with: Entities::UserBaseInfo, documentation: {type: Entities::UserBaseInfo, desc: '发件人'}

    expose :email_tos, as: :tos, with: Entities::EmailTo, documentation: {type: Entities::EmailTo, desc: '收件人', is_array: true}

    expose :cc_relations, as: :ccs, with: Entities::EmailReceiver, documentation: {type: Entities::EmailReceiver, desc: '抄送人', is_array: true}
  end
end
