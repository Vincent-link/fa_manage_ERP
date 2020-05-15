class OrganizationTeamApi < Grape::API
  mounted do
    resource :organizations do
      resource ':id' do
        before do
          @organization = Organization.find params[:id]
        end

        desc '机构团队', entity: Entities::OrganizationTeam
        get :teams do
          present @organization.organization_teams, with: Entities::OrganizationTeam
        end

        desc '创建机构团队', entity: Entities::OrganizationTeam
        params do
          requires :name, type: String, desc: '名称'
        end
        post :teams do
          team = @organization.organization_teams.find_or_create_by declared(params)

          present team, with: Entities::OrganizationTeam
        end
      end
    end
  end

  resource :organization_teams do
    resource ':id' do
      desc '删除机构团队'
      delete do
        OrganizationTeam.find(params[:id]).destroy!
      end
    end
  end
end