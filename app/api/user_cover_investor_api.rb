class UserCoverInvestorApi < Grape::API
  resource :user_cover_investors do
    desc '我覆盖的投资人', entity: Array[Entities::UserCoverInvestor]
    get do
      present User.current.member_user_relations, with: Entities::UserCoverInvestor
    end

    desc '新增我覆盖的投资人', entity: Entities::UserCoverInvestor
    params do
      requires :member_id, type: Integer, desc: '投资人id'
      requires :is_kpi, type: Boolean, desc: '是否用于kpi统计'
    end
    post do
      present User.current.member_user_relations.create!(declared(params)), with: Entities::UserCoverInvestor
    end

    resource ':id' do
      before do
        @member_user_relation = User.current.member_user_relations.find(params[:id])
      end

      desc '删除我覆盖的投资人'
      delete do
        @member_user_relation.destroy!
      end
    end
  end
end
