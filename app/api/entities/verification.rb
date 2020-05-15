module Entities
  class Verification < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :verification_type, documentation: {type: 'string', desc: '类型', required: true}
    expose :status, documentation: {type: 'string', desc: '状态', required: true}
    expose :desc, documentation: {type: 'integer', desc: '描述', required: true}

    expose :rejection_reason, documentation: {type: 'string', desc: '拒绝理由', required: true}
    expose :sponsor, documentation: {type: 'string', desc: '发起人', required: true}
    expose :funding_id, documentation: {type: 'integer', desc: '项目id', required: true}
    expose :before, documentation: {type: 'string', desc: '修改前title', required: true}

    expose :after, documentation: {type: 'string', desc: '修改前title', required: true}
    expose :company_id, documentation: {type: 'string', desc: '公司', required: true}
  end
end