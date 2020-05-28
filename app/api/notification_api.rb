class NotificationApi < Grape::API
  resource :notifications do
    desc '通知', entity: Entities::Notification
    params do
      optional :notification_type, type: String, desc: '类型', values: ["ir_review", "project", "investor"]
      optional :is_read, type: Boolean, desc: '是否已读', values: [true, false]
    end
    get do
      notifications = User.current.notifications.where(notification_type: params[:notification_type])
      notifications = notifications.where(is_read: params[:is_read]) unless params[:is_read].nil?
      present notifications, with: Entities::Notification
    end

    desc '通知都标记为已读', entity: Entities::Notification
    params do
      optional :notification_type, type: String, desc: '类型', values: ["ir_review", "project", "investor"]
    end
    patch :read_all_notification do
      notifications = User.current.notifications.where(notification_type: params[:notification_type], is_read: nil).update(is_read: true)
      present notifications, with: Entities::Notification
    end
  end
end
