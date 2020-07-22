module NotificationExtend
  extend ActiveSupport::Concern

  included do

    def create_ir_review_notification(organization_id, summary)
      if organization_id.present?
        organization = Organization.find(organization_id)

        content = Notification.notification_type_config[:ir_review][:content].call(User.current.name, organization.name) if organization.name.present?
        Notification.create(notification_type: Notification.notification_type_value("ir_review"), content: content, is_read: false, notice: {organization_id: organization.id}) if content.present?
      end
    end

  end
end
