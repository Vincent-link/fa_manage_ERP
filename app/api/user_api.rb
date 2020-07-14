class UserApi < Grape::API
  resource :users do
    desc '获取当前登录用户', entity: Entities::UserMyCurrent
    get :me do
      present current_user, with: Entities::UserMyCurrent
    end

    desc '登出'
    post :logout do
      logout
      present true
    end

    desc '退出代理'
    post :unproxy do
      unproxy
      present true
    end

    desc '获取所有用户', entity: Entities::UserForIndex
    params do
      optional :bu_id, type: Integer, desc: '部门id'
      optional :query, type: String, desc: '检索姓名'
      optional :layout, type: String, desc: '样式', values: ['lite', 'index'], default: 'index'
    end
    get do
      users = User.includes(:roles).order(grade_id: :desc)
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

      desc '获取用户'
      get do
        present @user, with: Entities::UserForShow
      end

      desc '更新用户', entity: Entities::UserForShow
      params do
        optional :avatar_file, type: Hash, desc: '头像' do
          optional :blob_id, type: Integer, desc: 'blob_id 新文件id'
        end
        optional :tel, type: String, desc: '手机'
        optional :wechat, type: String, desc: '微信'
        optional :user_title_id, type: Integer, desc: 'title_id'
      end
      patch do
        @user.update! declared(params, include_missing: false)
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

      desc '已选权限点', entity: Entities::Resource
      get :resources do
        user_roles = @user.user_roles
        resources = Resource.resources.select {|e| RoleResource.where(role_id: user_roles.pluck(:role_id)).pluck(:name).include?(e.name)}
        present resources, with: Entities::Resource
      end

      desc '更新用户权限组'
      params do
        optional 'ids', type: Array[String], desc: "权限组"
      end
      patch :roles do
        @roles = Role.all.select {|e| params[:ids].include?(e.id.to_s)} unless params[:ids].nil?
        @user.role_ids = @roles.map(&:id) unless @roles.nil?
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

      desc "我的kpi"
      params do
        requires :year, type: Integer, desc: "年度", default: 2020
      end
      get :my_kpi do
        if !@user.kpi_group.nil?
          kpis = @user.kpi_group.kpis.where("extract(year from kpis.created_at)  = ?", params[:year])
        else
          raise "没有配置kpi"
        end
        present kpis, with: Entities::StatisKpiForMe, user_id: @user.id
      end
    end
  end
end
