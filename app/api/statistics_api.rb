class StatisticsApi < Grape::API
  resources :statistics do
    resources :kpis do
      desc "管理员"
      params do
        requires :year, type: Integer, desc: "年度", default: 2020
      end
      get do
        teams = Team.order(created_at: :desc)
        present teams, with: Entities::StatisKpiForAdmin, year: params[:year]
      end

      desc "下级kpi统计"
      params do
        requires :year, type: Integer, desc: "年度", default: 2020
      end
      get :sub_users_kpi do
        present User.current, with: Entities::StatisKpiForUser, year: params[:year]
      end
    end

    resources :pipelines do
      desc 'Pipeline概览'
      params do
        optional :year, type: Integer, desc: '搜索的年份', default: Date.current.year
        optional :month, type: Integer, desc: '搜索的月份', default: Date.current.month
      end

      get :overview do
        res = Pipeline.group_by_status_type(params)
        present res
      end

      desc 'Pipeline分组概览'
      params do
        optional :year, type: Integer, desc: '搜索的年份', default: Date.current.year
        optional :month, type: Integer, desc: '搜索的月份', default: Date.current.month
      end

      get :team_overview do
        res = Pipeline.group_by_team(params)
        present res
      end

      desc 'Pipeline 预测收入和年内概率收入饼图'
      params do
        optional :year, type: Integer, desc: '搜索的年份', default: Date.current.year
        optional :month, type: Integer, desc: '搜索的月份', default: Date.current.month
      end

      get :pie_for_bu do
        res = Pipeline.statistic_pie_for_bu(params)
        present res
      end

      desc 'Pipeline 按时间维度统计'
      params do
        optional :year, type: Integer, desc: '搜索的年份', default: Date.current.year
        optional :month, type: Integer, desc: '搜索的月份', default: Date.current.month
      end

      get :statistic_by_month do
        res = Pipeline.statistic_by_est_bill_date(params)
        present res
      end
    end
  end
end
