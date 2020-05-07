class UserInvestorGroupApi < Grape::API
  resource :user_investor_groups do
    desc '个人投资人组列表', entity: Array[Entities::UserInvestorGroup]
    get do
      present UserInvestorGroup.all, with: Entities::UserInvestorGroup
    end

    desc '创建个人投资人组', entity: Entities::UserInvestorGroup
    params do
      requires :name, type: String, desc: '组名称'
      requires :is_public, type: Boolean, desc: '是否公开'
    end
    post do
      present UserInvestorGroup.create!(declared(params)), with: Entities::UserInvestorGroup
    end

    resource ':id' do
      before do
        @user_investor_group = UserInvestorGroup.find(params[:id])
      end

      desc '删除个人投资人组'
      delete do
        @user_investor_group.destroy!
      end

      desc '更新个人投资人组', entity: Entities::UserInvestorGroup
      params do
        requires :name, type: String, desc: '组名称'
        requires :is_public, type: Boolean, desc: '是否公开'
      end
      patch do
        present @user_investor_group.update(declared(params)), with: Entities::UserInvestorGroup
      end
    end
  end
end