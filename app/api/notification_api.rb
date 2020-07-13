class NotificationApi < Grape::API
  resource :notifications do
    desc '通知', entity: Entities::Notification
    params do
      optional :notification_type, type: String, desc: '类型', values: ["ir_review", "project", "investor"]
      optional :is_read, type: Boolean, desc: '是否已读', values: [true, false]
      optional :page, type: Integer, desc: '页数', default: 1
      optional :page_size, as: :per_page, type: Integer, desc: '页数', default: 10
    end
    get do
      # 如果不选，表示全部通知
      params[:notification_type] = Notification.notification_type_config[params[:notification_type].to_sym][:value] unless params[:notification_type].nil?
      params[:notification_type] ||= [1,2,3]
      params[:is_read] = [true, false] if params[:is_read].nil?

      notifications = User.current.notifications.where(notification_type: params[:notification_type], is_read: params[:is_read]).paginate(page: params[:page], per_page: params[:per_page])
      present notifications, with: Entities::Notification
    end

    desc '所有通知标记为已读', entity: Entities::Notification
    patch :read_all_notification do
      notifications = User.current.notifications.where(is_read: false)
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

    desc '通知类型和未读通知数'
    get :notification_types do
      arr = []
      [1,2,3].map do |type|
        row = {}
        row[:type] = Notification.notification_type_desc_for_value(type)
        row[:unread_num] = User.current.notifications.where(notification_type: type, is_read: false).count
        arr << row
      end
      present arr, with: Entities::NotificationType
    end
  end
end
