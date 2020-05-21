module Entities
  class Notification < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :notification_type, documentation: {type: 'string', desc: '类型', required: true}
    expose :content, documentation: {type: 'string', desc: '内容', required: true}
    expose :is_read, documentation: {type: 'string', desc: '状态', required: true}
    expose :notice, documentation: {type: 'string', desc: '其他字段', required: true}

    # expose :user, using: Entities::User
    # expose :funding_id, documentation: {type: 'integer', desc: '项目id', required: true}
    # expose :before, documentation: {type: 'string', desc: '修改前title', required: true}

    # expose :after, documentation: {type: 'string', desc: '修改前title', required: true}
    # expose :company_id, documentation: {type: 'string', desc: '公司', required: true}
  end
end
