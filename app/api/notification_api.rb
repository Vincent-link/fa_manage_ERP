class NotificationApi < Grape::API
  resource :notifications do
    desc '通知', entity: Entities::Notification
    params do
      optional :notification_type, type: String, desc: '类型', values: ["ir_review", "project", "investor"]
      optional :is_read, type: Boolean, desc: '是否已读'
      optional :page, type: Integer, desc: '页数', default: 1
      optional :page_size, as: :per_page, type: Integer, desc: '页数', default: 10
    end
    get do
      params[:notification_type] ||= ["ir_review", "project", "investor"]
      params[:is_read] ||= [true, false]
      notifications = User.current.notifications.where(notification_type: params[:notification_type], is_read: params[:is_read]).paginate(page: params[:page], per_page: params[:per_page])
      present notifications, with: Entities::Notification
    end

    desc '所有通知标记为已读', entity: Entities::Notification
    patch :read_all_notification do
      notifications = User.current.notifications.where(is_read: nil)
      notifications.update_all(is_read: true)
      present notifications, with: Entities::Notification
    end

    desc '单个通知标记为已读', entity: Entities::Notification
    params do
      requires :notification_id, type: Integer, desc: "通知id"
    end
    patch :read_single_notification do
      notification = Notification.find(params[:notification_id])
      notification.update(is_read: true)
      present notification, with: Entities::Notification
    end
  end
end
