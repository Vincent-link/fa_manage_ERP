class KpiApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':id' do
        desc '获取所有kpi'
        get do

        end

        desc '创建kpi'
        params do
          requires :kpi_type, type: Integer, desc: "类型"
          requires :coverage, type: Integer, desc: "范围"
          requires :value, type: Integer, desc: "值"
          requires :desc, type: String, desc: "描述"
          requires :relation, type: String, desc: "关系", values: ["or", "and"]
        end
        post do

        end
        resources :kpi do
          resource ':id' do
            before do
              @kpi = Kpi.find(params[:id])
            end

            desc "编辑kpi"
            params do
              requires :kpi_type, type: Integer, desc: "类型"
              requires :coverage, type: Integer, desc: "范围"
              requires :value, type: Integer, desc: "值"
              requires :desc, type: String, desc: "描述"
              requires :relation, type: String, desc: "关系", values: ["or", "and"]
            end
            patch do

            end

            desc "删除kpi"
            delete do

            end
          end
        end

      end
    end
  end

end
