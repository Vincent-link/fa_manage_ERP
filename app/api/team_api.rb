class TeamApi < Grape::API
  resource :teams do
    desc '所有team', entity: Entities::Team
    get do
      present Team.all, with: Entities::Team
    end

    desc "新增team"
    params do
      optional :name, type: String, desc: '团队名称'
      optional :serial, type: Integer, desc: ''
    end
    post do
      Team.create!(declared(params))
    end

    desc '获取BU', entity: Entities::TeamLite
    get :bu do
      present Team.where(parent_id: 242), with: Entities::TeamLite
    end

    resources ':id' do
      before do
        @team = Team.find(params[:id])
      end

      desc '删除'
      delete do
        @team.destroy!
      end

      desc '更新'
      params do
        requires :name, type: String, desc: '名称'
      end
      patch do
        @team.update(declared(params))
      end
    end
  end

  mount KpiGroupApi, with: {owner: "teams"}
end
