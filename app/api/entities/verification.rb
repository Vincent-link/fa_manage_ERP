module Entities
  class Verification < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :verification_type, documentation: {type: 'string', desc: '类型', required: true}
    expose :status, documentation: {type: 'string', desc: '状态', required: true}
    expose :desc, documentation: {type: 'integer', desc: '描述', required: true}

    expose :rejection_reason, documentation: {type: 'string', desc: '拒绝理由', required: true}
    expose :sponsor, documentation: {type: 'string', desc: '发起人', required: true}
    expose :verifi, documentation: {type: 'string', desc: '发起人', required: true}
    expose :created_at, documentation: {type: 'string', desc: '发起人', required: true}
  end
end
