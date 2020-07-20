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
          requires :name, type: Array[String], desc: '名称'
        end
        post :teams do
          @organization.organization_teams.where.not(name: params[:name]).destroy_all
          params[:name].each do |name|
            @organization.organization_teams.find_or_create_by name
          end
          present @organization.organization_teams, with: Entities::OrganizationTeam
        end
      end
    end
  end
end