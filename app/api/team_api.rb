class TeamApi < Grape::API
  resource :teams do
    desc '所有team', entity: Entities::Team
    params do
      optional :range, type: String, desc: '范围', values: ['bu_team', 'all_team'], default: 'bu_team'
    end
    get do
      case params[:range]
      when 'bu_team'
        present Team.where(parent_id: Settings.current_bu_id), with: Entities::Team
      when 'all_team'
        present Team.all, with: Entities::Team
      end
    end

    desc 'sub_team', entity: Entities::Team
    params do
      optional :team_id, type: String, desc: '团队', values: ['bu_team', 'all_team'], default: 'bu_team'
    end
    get do
      case params[:range]
      when 'bu_team'
        present Team.where(parent_id: Settings.current_bu_id), with: Entities::Team
      when 'all_team'
        present Team.all, with: Entities::Team
      end
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
      present Team.where(parent_id: Settings.current_bu_id), with: Entities::TeamLite
    end

    resources ':id' do
      before do
        @team = Team.find(params[:id])
      end

      desc '子团队'
      get :sub_team do
        present @team.sub_teams, with: Entities::Team
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

      desc '团队成员'
      get :users do
        present @team.users, with: Entities::UserLite
      end
    end
  end

  mount KpiGroupApi, with: {owner: "teams"}
end
