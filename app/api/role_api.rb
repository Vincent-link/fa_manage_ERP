class RoleApi < Grape::API
  resource :roles do

    desc '所有权限组'
    get do
      present Role.all, with: Entities::RoleForShow
    end

    desc "新增权限组"
    params do
      optional :name, type: String, desc: '权限组'
      optional :desc, type: String, desc: '说明'
    end
    post do
      present Role.create!(params), with: Entities::RoleForShow
    end

    resources ':id' do
      before do
        @role = Role.find(params[:id])
      end

      desc '查看和编辑权限组', entity: Entities::RoleForShow
      get do
        present @role, with: Entities::RoleForShow
      end

      desc '获取单个权限组权限'
      get :resources do
        @role_resources = Resource.resources.select{|e| RoleResource.where(role_id: params[:id]).pluck(:name).include?(e.name)}        
        present @role_resources, with: Entities::RoleResource
      end

      desc '更新单个权限组权限'
      params do
        optional 'names[]', type: Array[String], desc: "权限"
      end
      patch :resources do
        @resources = Resource.resources.select { |e| params[:names].include?(e.name) }
        @role.resource_ids = @resources.map(&:name)
        present @role.role_resources, with: Entities::RoleResource
      end

      desc '获取权限组所有用户'
      get :users do
        @role_users = User.joins(:user_roles).where(user_roles: {role_id: params[:id], deleted_at: nil})
        present @role_users, with: Entities::User
      end

      desc '更新权限组用户'
      params do
        optional 'ids[]', type: Array[String], desc: "用户ID"
      end
      patch :users do
        @users = User.all.select { |e| params[:ids].include?(e.id.to_s) }
        @role.user_ids = @users.map(&:id)
        present @role.user_roles, with: Entities::UserRole
      end

      desc '删除权限组'
      delete do
        @role.destroy!
      end

      desc '更新权限组名称'
      params do
        requires :name, type: String, desc: '名称'
      end
      patch :name do
        re = params if @role.update(declared(params))
        present re, with: Entities::RoleForShow
      end

      desc '更新权限组说明'
      params do
        requires :desc, type: String, desc: '说明'
      end
      patch :desc do
        re = params if @role.update(declared(params))
        present re, with: Entities::RoleForShow
      end
      
    end

  end
end