module Entities
  class Verification < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :verification_type, documentation: {type: 'integer', desc: '类型', required: true}
    expose :status, documentation: {type: 'string', desc: '状态', required: true}
    expose :desc, documentation: {type: 'integer', desc: '描述', required: true}

    expose :rejection_reason, documentation: {type: 'string', desc: '拒绝理由', required: true}
    expose :sponsor, using: Entities::UserLite, documentation: {type: 'string', desc: '发起人', required: true}
    expose :verifi, documentation: {type: 'string', desc: '其他字段', required: true}
    expose :created_at, documentation: {type: 'string', desc: '创建时间', required: true}
  end
end
