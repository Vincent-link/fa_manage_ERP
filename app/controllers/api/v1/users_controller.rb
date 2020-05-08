class Api::V1::UsersController < Api::V1::BaseController
  layout 'react_app'

  swagger_controller :users, "Users"

  swagger_api :index do
    summary "Fetch all users contains deleted"
    notes "This lists all users though be deleted"
    param :query, :with_deleted, :boolean, :optional, "with deleted tag, will be true or false"
  end

  def index
    scope = params[:with_deleted].to_s == 'true' ? ::User.with_deleted : ::User.all
    @users = scope.order("deleted_at desc").order(:id)
  end

  swagger_api :auth do
    summary "Auth interface"
  end

  def auth
  end

  swagger_api :check_email_authorize_req_feedback do
    summary "邮箱验证"
    response :unauthorized
    response :not_acceptable
  end
  def check_email_authorize_req_feedback
    unless current_user.valid_email_password?
      @error_msg = '邮箱未授权'
    end
  end

  swagger_api :sso_users do
    summary "获取sso Users"
    param :query, :with_deleted, :boolean, :optional, '0 or 1'
  end

  def sso_users
    scope = params[:with_deleted].to_s == '1' ? Zombie::SsoUser.with_deleted : Zombie::SsoUser.all
    @users = scope.order("deleted_at desc").order(:id).select(:id, :name, :email, :deleted_at)
    render :index
  end

  swagger_api :roles do
    summary '查看用户角色'
    param :path, :id, :integer, :require
  end
  def roles
    user = User.find params[:id]
    @roles = user.roles
    render 'api/v1/roles/index'
  end

  swagger_api :edit_roles do
    summary '编辑用户角色'
    param :path, :id, :integer, :require
    param :form, :'role_id[]', :array, :require
  end
  def edit_roles
    user = User.find params[:id]
    @roles = user.roles = Role.where(id: params[:role_id])
    render 'api/v1/roles/index'
  end

  swagger_api :resources do
    summary '查看用户权限'
    param :path, :id, :integer, :require
  end
  def resources
    user = User.find params[:id]
    user_all_role_resources = user.all_role_resources
    @resources = Resource.resources.select { |e| user_all_role_resources.include?(e.name) }
    render 'api/v1/resources/index'
  end
end
