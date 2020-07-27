namespace :send_report_email do
  desc "发送日报周报"

  task daily: :environment do
    User.all.each{|user| DailyReportEmailJob.perform_later(user)}
  end

  task weekly: :environment do

  end
end
