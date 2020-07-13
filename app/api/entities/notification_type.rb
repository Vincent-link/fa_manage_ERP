module Entities
  class NotificationType < Base
    expose :type, documentation: {type: 'integer', desc: '类型', required: true}
    expose :unread_num, documentation: {type: 'integer', desc: '未读数量', required: true}
  end
end
