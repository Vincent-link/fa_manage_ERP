module Entities
  class Question < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :desc, documentation: {type: 'integer', desc: '描述', required: true}
    expose :name, documentation: {type: 'integer', desc: '用户名称', required: true}
    expose :avatar, documentation: {type: 'integer', desc: '用户头像', required: true}
    expose :created_at, documentation: {type: 'integer', desc: '提交问题时间', required: true}
  end
end