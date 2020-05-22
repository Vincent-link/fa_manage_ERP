module Entities
  class Question < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :desc, documentation: {type: 'integer', desc: '描述', required: true}
    expose :user, using: Entities::User
    # expose :avatar, using: Entities::File, if: ->(ins) {ins.avatar.present?}, documentation: {type: Entities::File, desc: '用户头像', required: true}
    expose :created_at, documentation: {type: 'integer', desc: '提交问题时间', required: true}
  end
end
