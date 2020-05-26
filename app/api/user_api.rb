class UserApi < Grape::API
  resource :users do
    desc '获取当前登录用户', entity: Entities::User
    get :me do
      present current_user, with: Entities::User
    end

    desc '登出'
    post :logout do
      logout
    end

    desc '退出代理'
    post :unproxy do
      unproxy
      present 200
    end

    desc '获取所有用户', entity: Entities::UserForIndex
    params do
      optional :bu_id, type: Integer, desc: '部门id'
      optional :query, type: String, desc: '检索姓名'
      optional :layout, type: String, desc: '样式', values: ['lite', 'index'], default: 'index'
    end
    get do
      users = User.all
      users = users.where(bu_id: params[:bu_id]) if params[:bu_id].present?
      users = users.where('name like ?', "%#{params[:query]}%") if params[:query].present?

      case params[:layout]
      when 'index'
        present users, with: Entities::UserForIndex
      when 'lite'
        present users, with: Entities::UserLite
      end
    end

    resource ':id' do
      before do
        @user = User.find(params[:id])
      end

      desc '更新用户', entity: Entities::UserForShow
      params do
        requires :avatar, type: File, desc: '头像'
      end
      patch do
        params[:avatar] = ActionDispatch::Http::UploadedFile.new(params[:avatar]) if params[:avatar]
        @user.update! declared(params)
        present @user, with: Entities::UserForShow
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

      desc '已选权限组', entity: Entities::Role
      get :roles do
        selected_roles = Role.joins(:user_roles).where(user_roles: {user_id: params[:id], deleted_at: nil})
        present selected_roles, with: Entities::Role
      end

      desc '更新用户权限组', entity: Entities::UserRole
      params do
        optional 'ids', type: Array[String], desc: "权限组"
      end
      patch :roles do
        @roles = Role.all.select { |e| params[:ids].include?(e.id.to_s) } unless params[:ids].nil?
        @user.role_ids = @roles.map(&:id) unless @roles.nil?

        present @role.user_roles, with: Entities::UserRole
      end

      desc '增加一个权限组', entity: Entities::Role
      params do
        optional 'role_id', type: Integer, desc: "权限组"
      end
      post :role do
        @user.add_role_by_id(params[:role_id])
        present Role.find(params[:role_id]), with: Entities::Role
      end

      desc '删除一个权限组', entity: Entities::Role
      params do
        optional 'role_id', type: Integer, desc: "权限组"
      end
      delete :role do
        @user.delete_role_by_id(params[:role_id])
        present Role.find(params[:role_id]), with: Entities::Role
      end

      desc '更新上级负责人', entity: Entities::UserLite
      params do
        requires 'leader_id', type: Integer, desc: "上级负责人"
      end
      patch :leader do
        @user.update(declared(params))

        present User.find_by(id: params[:leader_id]), with: Entities::UserLite
      end

      desc '更新对外title', entity: Entities::UserTitle
      params do
        requires 'user_title_id', type: Integer, desc: "对外title"
      end
      patch :user_title do
        @user.update_title(declared(params))
        @user_title = UserTitle.find(params[:user_title_id])
        present @user_title, with: Entities::UserTitle
      end
    end
  end

  mount VerificationApi, with: {owner: 'users'}
  mount NotificationApi, with: {owner: 'users'}
end
