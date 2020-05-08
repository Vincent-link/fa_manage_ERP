class Api::V1::BaseController < ActionController::Base
  include Swagger::Docs::ImpotentMethods
  before_action :authenticate_user! if Rails.env != 'development'
  before_action :record_access_log

  rescue_from Exception, with: :show_errors
  # 此处需修改掉，底层数据找不到会抛个RuntimeError出来，底层修改后即可修改--已改
  rescue_from RuntimeError, with: :exception_errors
  rescue_from CanCan::AccessDenied, with: :authority_error
  rescue_from ActiveRecord::ActiveRecordError, with: :record_error
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordNotDestroyed, with: :record_error
  rescue_from HexaPDF::MalformedPDFError, with: :pdf_broken


  around_action :do_with_current_user

  def do_with_current_user
    Zombie.current_user = current_user.sso_id if current_user
    User.current = self.current_user
    begin
      yield
    ensure
      User.current = nil
      Zombie.current_user = nil
    end
  end

  def sanitize_json_params(options)
    options.is_a?(ActionController::Parameters) ? options.values : options
  end

  def escape_character(query)
    query = query.to_s.strip
    if query.gsub(/[A-Za-z0-9_\s\-\.]/, "").present?
      query.gsub(/[^\u4e00-\u9fa5A-Za-z0-9_\.]/, "")
    else
      query.gsub(/[^\u4e00-\u9fa5A-Za-z0-9_\s\-\.]/, "")
    end
  end

  private

  def token_auth?
    return false unless request.authorization
    token = OAuth2::AccessToken.new SsoClient.client, request.authorization.gsub('Bearer ', '')
    return token.get('api/auth') rescue false
  end

  def exception_errors(exception)
    @error = exception.message || "系统异常"
    logger.error @error
    print_exception(exception)
    error_response
  end

  def show_errors(exception)
    @error = "服务异常，请联系开发人员"
    print_exception(exception)
    error_response
  end

  def record_not_found(exception)
    @error = "该记录不存在"
    logger.error @error
    print_exception(exception)
    error_response
  end

  def authority_error
    respond_to do |format|
      format.json {render json: {code: 401, message: "您没有当前操作权限"}}
    end
  end

  def record_error(exception)
    @error = exception.record.errors.full_messages.join("，")
    logger.error @error
    print_exception(exception)
    error_response
  end

  def pdf_broken
    @error = @error_msg = '无法打开已损坏的PDF，请联系系统管理员'
    error_response
  end

  def error_response
    respond_to do |format|
      format.js {render js: "Message.error('" + @error + "')"}
      format.json {render json: {code: 500, message: @error}}
      format.html {render 'common/error_page'}
    end
  end

  def print_exception(exception)
    logger.error exception.inspect
    logger.error exception.backtrace.join("\n")
    Common::Message.send_sms(exception.message())
    Honeybadger.notify(exception) if Object.const_defined?('Honeybadger')
  end

  def record_access_log
    exceptions = %w(controller action format)
    ActiveSupport::Notifications.instrument "arrow.event", {
        klass: 'event',
        user_id: current_user&.id,
        method: request.request_method,
        controller: params[:controller],
        params: params.except(*exceptions),
        action: params[:action],
        remote_ip: request.remote_ip
    }
  end

  def page_params(default_page_size = nil)
    {
        page: params[:page].present? ? params[:page].to_i : 1,
        per_page: params[:page_size].present? ? params[:page_size].to_i : (default_page_size || 10)
    }
  end

  def request_data_params
    params
  end
end
