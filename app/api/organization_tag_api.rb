class OrganizationTagApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':organization_tag_category_id' do

        desc '标签类别对应标签', entity: Entities::OrganizationTag
        get :tags do
          @organization_tags = OrganizationTag.where(organization_tag_category_id: params[:organization_tag_category_id])
          present @organization_tags, with: Entities::OrganizationTag
        end

        desc '新增标签', entity: Entities::OrganizationTag
        params do
          optional :name, type: String, desc: '名称'
          optional :id, as: :organization_tag_category_id, type: Integer, desc: '标签类别ID'
        end
        post :tags do
          present OrganizationTag.create!(declared(params)), with: Entities::OrganizationTag
        end

      end
    end
  end

  resource :organization_tags do
    resources ':id' do
      before do
        @organization_tag = OrganizationTag.find(params[:id])
      end

      desc '删除标签'
      delete do
        @organization_tag.destroy!
      end

      desc '更新标签', entity: Entities::OrganizationTag
      params do
        requires :name, type: String, desc: '名称'
      end
      patch do
        @organization_tag.update(declared(params))

        present @organization_tag, with: Entities::OrganizationTag
      end
    end
  end
end
