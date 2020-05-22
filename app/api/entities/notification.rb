module Entities
  class Notification < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :notification_type, documentation: {type: 'string', desc: '类型', required: true}
    expose :content, documentation: {type: 'string', desc: '内容', required: true}
    expose :is_read, documentation: {type: 'string', desc: '状态', required: true}
    expose :notice, documentation: {type: 'string', desc: '其他字段', required: true}
  end
end
