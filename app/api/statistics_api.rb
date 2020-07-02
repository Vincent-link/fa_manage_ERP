class StatisticsApi < Grape::API
  resources :statistics do
    resources :kpis do
      desc "管理员"
      params do
        requires :year, type: Integer, desc: "年度", default: 2020
      end
      get do
        # teams = Team.where("extract(year from created_at) = ?", params[:year]).order(created_at: :desc)
        # res = []
        # teams.each_with_index do |kpi, i|
        #   types = ["目标", "约见公司"]
        #   types.each_with_index do |type, j|
        #   end
        # end
        # kpis
      end
    end

  end
end
