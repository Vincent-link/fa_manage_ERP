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
    params do
      optional :bu_id, type: Integer, desc: '部门id'
    end
    get do
      if params[:bu_id].nil?
        present User.all, with: Entities::User
      else
        present User.where(bu_id: params[:bu_id]), with: Entities::User
      end
    end

    resource ':id' do
      before do
        @user = User.find(params[:id])
      end

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

      desc '已选权限组'
      get :selected_roles do
        selected_roles = Role.joins(:user_roles).where(user_roles: {user_id: params[:id], deleted_at: nil})
        present selected_roles, with: Entities::Roles
      end

      desc '更新用户权限组'
      params do
        optional 'ids', type: Array[String], desc: "权限组"
      end
      patch :roles do
        @roles = Role.all.select { |e| params[:ids].include?(e.id.to_s) } unless params[:ids].nil?
        @user.role_ids = @roles.map(&:id) unless @roles.nil?

        present @user.user_roles, with: Entities::UserRole
      end

      desc '增加一个权限组'
      params do
        optional 'role_id', type: Integer, desc: "权限组"
      end
      patch :role do
        @user.add_role_by_id(params[:role_id])
        present @user.user_roles, with: Entities::UserRole
      end

      desc '删除一个权限组'
      params do
        optional 'role_id', type: Integer, desc: "权限组"
      end
      delete :role do
        @user.delete_role_by_id(params[:role_id])

        present @user.user_roles, with: Entities::UserRole
      end      

      desc '更新上级负责人'
      params do
        requires 'leader_id', type: Integer, desc: "上级负责人"
      end
      patch :leader do
        @user.update(declared(params))

        present User.find_by(id: params[:leader_id]), with: Entities::UserLite
      end

      desc '更新对外title'
      params do
        requires 'user_title_id', type: Integer, desc: "对外title"
      end
      patch :user_title do
        @user.update(declared(params))

        present @user.user_title, with: Entities::UserTitle
      end

    end
  end

  mount VerificationApi, with: {owner: 'users'}
end