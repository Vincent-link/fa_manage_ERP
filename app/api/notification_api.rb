class NotificationApi < Grape::API
  resource :notifications do
    desc '通知', entity: Entities::Notification
    params do
      requires :notification_type, type: String, desc: '类型', values: ["ir_review", "project", "investor"]
      optional :is_read, type: Boolean, desc: '是否已读'
    end
    get do
      notifications = User.current.notifications.where(notification_type: params[:notification_type], is_read: params[:is_read])
      present notifications, with: Entities::Notification
    end

    desc '通知都标记为已读', entity: Entities::Notification
    patch :read_all_notification do
      notifications = User.current.notifications.where(is_read: nil)
      notifications.map {|e| e.update(is_read: true)}
      present notifications, with: Entities::Notification
    end
  end
end
