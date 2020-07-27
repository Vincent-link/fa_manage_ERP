class UserInvestorGroupApi < Grape::API
  resource :user_investor_groups do
    desc '个人投资人组列表', entity: Array[Entities::UserInvestorGroup]
    get do
      group = UserInvestorGroup.where('is_public = true or user_id = ?', current_user.id)
      present group, with: Entities::UserInvestorGroup
    end

    desc '创建个人投资人组', entity: Entities::UserInvestorGroup
    params do
      requires :name, type: String, desc: '组名称'
      requires :is_public, type: Boolean, desc: '是否公开'
      optional :member_ids, type: Array[Integer], desc: '投资人id'
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
        optional :member_ids, type: Array[Integer], desc: '投资人id'
      end
      patch do
        @user_investor_group.update!(declared(params))
        present @user_investor_group, with: Entities::UserInvestorGroup
      end
    end
  end
end