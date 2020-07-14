class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  FROM = Settings.smtp.account
  CC   = Settings.smtp.cc

  SMTP_SERVER   = Settings.smtp.server
  SMTP_INTEL_SERVER = Settings.smtp_intel.server
  SMTP_PORT     = Settings.smtp.port
  SMTP_ACCOUNT  = Settings.smtp.account
  SMTP_PASSWORD = Settings.smtp.password
  SMTP_DOMAIN   = Settings.smtp.domain

  def delivery_mail!(options)
    unless Rails.env == 'production'
      to, cc = [options[:from]], [options[:from]]
      options[:to].each do |options_to|
        to << options_to if Settings.casual_email.include? options_to
      end
      options[:cc]&.each do |options_cc|
        cc << options_cc if Settings.casual_email.include? options_cc
      end
      options[:to] = to
      options[:cc] = cc

      Rails.logger.error to
    end
    mail(
        from:    options[:from],
        to:      options[:to],
        cc:      options[:cc],
        subject: options[:subject],
        delivery_method: :smtp,
        delivery_method_options: delivery_options(options[:user]),
        ).deliver!
  end

  def delivery_options(user = nil)
    {
        user_name:      user&.email || SMTP_ACCOUNT,
        password:       user&.email_password || SMTP_PASSWORD,
        address:        smtp_server_address(user),
        port:           SMTP_PORT,
        domain:         SMTP_DOMAIN,
        enable_starttls_auto: true,
        openssl_verify_mode:  'none',
        authentication: 'login'
    }
  end

  def smtp_server_address(user = nil)
    if user && user.is_a?(User) && user.email.to_s.strip.downcase.match(/chinarenaissance.com$/)
      SMTP_INTEL_SERVER
    else
      SMTP_SERVER
    end
  end
end
