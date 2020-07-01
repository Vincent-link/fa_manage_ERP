class KpiGroupApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':team_id' do
        desc '获取所有kpi组'
        get do
          KpiGroup.where(team_id: params[:id]).order(created_at: :desc)
        end

        desc '创建kpi组'
        params do
          requires :user_ids, type: Array[Integer], desc: "用户id"
        end
        post do
          @kpi_group = KpiGroup.create!()
          User.where(id: params[:user_ids]).map {|e| e.update(kpi_group_id: @kpi_group.id)}
        end

        resources :kpi_groups do
          resource ':id' do
            before do
              @kpi_group = KpiGroup.find(params[:id])
            end

            desc "编辑kpi组"
            params do
              requires :user_ids, type: Array[Integer], desc: "用户id"
            end
            patch do
              @kpi_group.users_ids = params[:user_ids]
            end

            desc "删除kpi组"
            delete do
              @kpi_group.destroy!
            end
          end
        end
      end
    end
  end

  mount KpiApi, with: {owner: "kpi_groups"}
end
