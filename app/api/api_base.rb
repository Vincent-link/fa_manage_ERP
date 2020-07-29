class ApiBase < Grape::API
  format :json
  content_type :json, "application/json"
  helpers ::Helpers::CommonHelpers

  formatter :json, ::Formatters::LayoutFormatter
  use ActionDispatch::Session::CookieStore
  use GrapeLogging::Middleware::RequestLogger,
      instrumentation_key: 'grape.request',
      include: [GrapeLogging::Loggers::FilterParameters.new,
                GrapeLogging::Loggers::RequestHeaders.new,
                GrapeLogging::Loggers::SessionInfo.new]
  before do
    authenticate_user! unless skip_auth?
    User.current = current_user
    if current_user
      Zombie.current_user = current_user.id
      PaperTrail.request.whodunnit = current_user.name
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    message = "您访问的数据已经失效，请刷新页面或后退重新访问"
    Honeybadger.notify(e) if Object.const_defined?('Honeybadger')
    error!({code: 404, msg: message}, 200)
  end if Rails.env.production?

  rescue_from CanCan::AccessDenied do
    message = "您没有操作权限！"
    error!({code: 401, msg: message}, 200)
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    message = e.record.errors.full_messages.join("，")
    Rails.logger.error message
    Honeybadger.notify(e) if Object.const_defined?('Honeybadger')
    error!({code: 422, msg: message}, 200)
  end

  rescue_from ActiveRecord::RecordNotDestroyed do |e|
    message = e.record.errors.full_messages.join("，")
    Rails.logger.error message
    Honeybadger.notify(e) if Object.const_defined?('Honeybadger')
    error!({code: 422, msg: message}, 200)
  end

  rescue_from Magazine::WarningException do |e|
    error!({code: 500, msg: e.message}, 200)
  end

  rescue_from :all do |e|
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    Honeybadger.notify(e) if Object.const_defined?('Honeybadger')
    error!({code: 500, msg: e.message}, 200)
  end

  mount UserApi
  mount CommonApi
  mount OrganizationApi
  mount MemberApi
  mount EcmGroupApi
  mount InvesteventApi
  mount UserInvestorGroupApi
  mount RoleApi
  mount ResourceApi
  mount UserTitleApi
  mount TagCategoryApi
  mount MemberResumeApi
  mount CalendarApi
  mount FundingStateMachineApi
  mount FundingApi
  # mount FundingCompanyContactApi
  mount VerificationApi
  mount NotificationApi
  mount FileApi
  mount PipelineApi
  mount TrackLogApi
  mount TrackLogDetailApi
  mount CompanyApi
  mount TeamApi
  mount EmailApi
  mount KnowledgeBaseApi
  mount StatisticsApi
  mount UserCoverInvestorApi
  mount EvaBatchApi

  add_swagger_documentation array_use_braces: true
end
