class RoleApi < Grape::API
  resource :roles do
    desc '所有权限组', entity: Entities::Role
    get do
      present Role.all, with: Entities::Role
    end

    desc "新增权限组", entity: Entities::Role
    params do
      optional :name, type: String, desc: '权限组'
      optional :desc, type: String, desc: '说明'
    end
    post do
      present Role.create!(declared(params)), with: Entities::Role
    end

    resources ':id' do
      before do
        @role = Role.find(params[:id])
      end

      desc '查看和编辑权限组', entity: Entities::Role
      get do
        present @role, with: Entities::Role
      end

      desc '获取单个权限组权限', entity: Entities::Resource
      get :resources do
        @role_resources = Resource.resources.select{|e| RoleResource.where(role_id: params[:id]).pluck(:name).include?(e.name)}
        present @role_resources, with: Entities::Resource
      end

      desc '更新单个权限组权限', entity: Entities::Resource
      params do
        optional :names, type: Array[String], desc: "权限"
      end
      patch :resources do
        params[:name] ||= []
        @resources = Resource.resources.select { |e| params[:names].include?(e.name) }
        @role.resource_ids = @resources.map(&:name)
        present @role.role_resources, with: Entities::Resource
      end

      desc '获取权限组所有用户', entity: Entities::User
      get :users do
        present @role.users, with: Entities::User
      end

      desc '更新权限组用户', entity: Entities::UserRole
      params do
        optional :ids, type: Array[Integer], desc: "用户ID"
      end
      patch :users do
        params[:ids] ||= []
        @users = User.select { |e| params[:ids].include?(e.id) }
        @role.user_ids = @users.map(&:id)
        present @role.user_roles, with: Entities::UserRole
      end

      desc '删除权限组'
      delete do
        @role.destroy!
      end

      desc '更新权限组名称', entity: Entities::Role
      params do
        requires :name, type: String, desc: '名称'
      end
      patch :name do
        @role.update(declared(params))
        present @role, with: Entities::Role
      end

      desc '更新权限组说明', entity: Entities::Role
      params do
        requires :desc, type: String, desc: '说明'
      end
      patch :desc do
        @role.update(declared(params))
        present @role, with: Entities::Role
      end
    end
  end
end
