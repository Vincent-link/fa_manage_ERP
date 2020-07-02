class KpiApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':id' do
        desc '获取组内所有kpi配置'
        get do
          kpis = Kpi.where(kpi_group_id: params[:id], parent_id: nil).order(created_at: :desc)
          present kpis, with: Entities::Kpi
        end

        desc '添加配置'
        params do
          requires :kpi_type, type: Integer, desc: "类型"
          requires :coverage, type: Integer, desc: "范围"
          requires :value, type: Integer, desc: "值"
          requires :desc, type: String, desc: "描述"
        end
        post do
          Kpi.create!(declared(params).merge(kpi_group_id: params[:id]))
        end
      end
    end
  end

  resources :kpi do
    desc '获取所有kpi类型'
    get :kpi_type do
      kpi_types = Kpi.kpi_type_id_name
      present kpi_types, with: Entities::KpiType
    end

    resource ':id' do
      before do
        @kpi = Kpi.find(params[:id])
      end

      desc "编辑配置"
      params do
        requires :kpi_type, type: Integer, desc: "类型"
        requires :coverage, type: Integer, desc: "范围"
        requires :value, type: Integer, desc: "值"
        requires :desc, type: String, desc: "描述"
      end
      patch do
        @kpi.update!(declared(params))
      end

      desc "删除"
      delete do
        @kpi.destroy!
      end

      desc "编辑条件"
      params do
        requires :kpi_type, type: Integer, desc: "类型"
        requires :coverage, type: Integer, desc: "范围"
        requires :value, type: Integer, desc: "值"
        requires :desc, type: String, desc: "描述"
        requires :relation, type: String, desc: "关系", values: ["or", "and"]
      end
      patch do
        @kpi.update!(declared(params))
      end

      desc '添加条件'
      params do
        requires :kpi_type, type: Integer, desc: "类型"
        requires :coverage, type: Integer, desc: "范围"
        requires :value, type: Integer, desc: "值"
        requires :desc, type: String, desc: "描述"
        requires :relation, type: String, desc: "关系", values: ["or", "and"]
      end
      post do
        Kpi.create!(declared(params).merge(kpi_group_id: @kpi.kpi_group_id, parent_id: params[:id]))
      end
    end
  end
end
