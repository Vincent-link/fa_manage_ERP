class OfficialPushEmailJob < ApplicationJob
  queue_as :default

  def perform(options, email_case, email_to_group_id, mark_string)
    begin
      send_email = EmailPushMailer.send_email_push(options, email_case, mark_string)
      puts "---------------#{send_email}---------------"
    rescue Exception => ex
      Rails.logger.error ex.inspect
      Rails.logger.error ex.backtrace.join("\n")
      email_case.email_to_groups.find(email_to_group_id).update(status: EmailToGroup.status_fail_value)
      email_case.reload
      status_list = email_case.email_to_groups.map(&:status).compact.uniq
      unless status_list.include? EmailToGroup.status_pushing_value
        if status_list.include? EmailToGroup.status_success_value
          email_case.update!(status: Email.status_incomplete_value)
        else
          email_case.update!(status: Email.status_fail_value)
        end
      end
    ensure
      email_case.email_to_groups.find(email_to_group_id).update(status: EmailToGroup.status_success_value)
      email_case.reload
      status_list = email_case.email_to_groups.map(&:status).compact.uniq
      unless status_list.include? EmailToGroup.status_pushing_value
        if status_list.include? EmailToGroup.status_fail_value
          email_case.update!(status: Email.status_incomplete_value)
        else
          email_case.update!(status: Email.status_success_value)
        end
      end
    end
  end
end
