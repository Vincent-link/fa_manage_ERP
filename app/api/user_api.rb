class UserApi < Grape::API
  resource :users do
    desc '获取当前登录用户'
    get :me do
      present current_user, with: Entities::User
    end

    desc '登出'
    post :logout do
      logout
      present 200
    end

    desc '退出代理'
    post :unproxy do
      unproxy
      present 200
    end

    desc '获取所有用户'
    get do
      present User.all, with: Entities::Users
    end

    desc '获取上级负责人'
    get :leader do
      present User.all, with: Entities::Leaders
    end

    desc '获取对外Title'
    get :user_title do
      present UserTitle.all, with: Entities::UserTitles
    end

    desc '按部门筛选'
    params do
      requires :bu_id, type: Integer, desc: '部门id'
    end
    get :bu do
      present User.where(bu_id: params[:bu_id]), with: Entities::Users
    end

    desc '导出用户列表'
    get :export_users do
      present User.all, with: Entities::Users
    end

    desc '所有权限组'
    get :roles do
      present Role.all, with: Entities::Roles
    end

    desc '已选权限组'
    get :selected_roles do
      selected_roles = Role.joins("INNER JOIN user_roles ON roles.id = user_roles.role_id AND user_roles.user_id = #{current_user.id}")
      present selected_roles, with: Entities::Roles
    end

    resource ':id' do
      desc '登录'
      post :login do
        raise 'not implement' if Rails.env.production?
        login(User.find_by_id(params[:id]))
        present current_user, with: Entities::User
      end

      desc '代理'
      post :proxy do
        authorize! :manage, :all
        proxy(User.find_by_id(params[:id]))
        present current_user, with: Entities::User
      end

      desc '更新用户权限'
      params do
        optional 'ids[]', type: Array[String], desc: "权限"
      end
      patch :update_resource do
        @user = User.find(params[:id])
        @roles = Role.all.select { |e| params[:ids].include?(e.id.to_s) }
        @user.role_ids = @roles.map(&:id)

        present @user.user_roles, with: Entities::UserRole
      end
    end
  end
end