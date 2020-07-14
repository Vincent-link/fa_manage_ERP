module Entities
  class EmailMsg < Base
    expose :title, documentation: {type: 'string', desc: '题目'}
    expose :greeting, documentation: {type: 'string', desc: '敬语'}
    expose :description, documentation: {type: 'string', desc: '正文'}
    expose :signature, documentation: {type: 'string', desc: '签名'}
  end
end
