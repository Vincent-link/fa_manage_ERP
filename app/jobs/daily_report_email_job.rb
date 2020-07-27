class DailyReportEmailJob < ApplicationJob
  queue_as :default

  def perform(user)
    ReportMailer.send_daily_report(user)
  end
end