class StatisticsApi < Grape::API
  resources :statistics do
    resources :kpis do
      desc "管理员"
      params do
        requires :year, type: Integer, desc: "年度", default: 2020
      end
      get do
        teams = Team.order(created_at: :desc)
        present teams, with: Entities::TeamForStatis
      end
    end

  end
end
