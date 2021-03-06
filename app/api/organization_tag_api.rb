class OrganizationTagApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':id' do
        desc '标签类别对应标签', entity: Entities::OrganizationTag
        get :tags do
          @organization_tags = OrganizationTag.where(organization_tag_category_id: params[:id])
          present @organization_tags, with: Entities::OrganizationTag
        end

        desc '新增标签', entity: Entities::OrganizationTag
        params do
          optional :name, type: String, desc: '名称'
        end
        post :tags do
          present OrganizationTag.create!(declared(params).merge(organization_tag_category_id: params[:id])), with: Entities::OrganizationTag
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
