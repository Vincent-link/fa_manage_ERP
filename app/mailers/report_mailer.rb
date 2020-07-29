class ReportMailer < ApplicationMailer
  def send_daily_report(user)
    @server_url = Settings.server_url

    sent_at = Time.current.midnight + 18.hours
    notifications = Notification.where("user_id is null or user_id = ?", user.id).where("created_at between ? and ?", sent_at - 1.days, sent_at)

    projects = notifications.notification_type_project.where("notice is not null").select{|notice| notice.notice["kind"] != nil}.group_by{|project| project.notice["kind"]}
    @projects_count = projects.count
    Notification.project_type_config.keys.each {|project_type_key| instance_variable_set("@projects_#{project_type_key}", projects[Notification.project_type_value(project_type_key)] || [])}

    # TODO ir_review 开关
    @ir_reviews = notifications.notification_type_ir_review
    @ir_reviews_count = @ir_reviews.count

    investors = notifications.notification_type_investor.where("notice is not null").select{|notice| notice.notice["kind"] != nil}.group_by{|investor| investor.notice["kind"]}
    @investors_count = investors.count
    Notification.investor_type_config.keys.each {|investor_type_key| instance_variable_set("@investors_#{investor_type_key}", investors[Notification.investor_type_value(investor_type_key)] || [])}

    delivery_mail!(email_params(user))
  end

  def send_weekly_report(user)
    delivery_mail!(email_params(user))
  end

  def email_params(user)
    {
      from: ApplicationMailer::SMTP_ACCOUNT,
      to: [user.email],
      subject: "每周投资者信息变动汇总（2020年4月19日-2020年4月26日）"
    }
  end
end
