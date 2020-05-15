class OrganizationTagCategoryApi < Grape::API
  resource :organization_tag_categories do

    desc '所有标签类别'
    get do
      present OrganizationTagCategory.all, with: Entities::OrganizationTagCategory
    end

    desc "新增标签类别"
    params do
      optional :name, type: String, desc: '名称'
    end
    post do
      present OrganizationTagCategory.create!(params), with: Entities::OrganizationTagCategory
    end

    resources ':id' do
      before do
        @organization_tag_category = OrganizationTagCategory.find(params[:id])
      end

      desc '删除标签类别'
      delete do
        @organization_tag_category.destroy!
      end

      desc '更新标签类别'
      params do
        requires :name, type: String, desc: '名称'
      end
      patch do
        re = params if @organization_tag_category.update(declared(params))
        present re, with: Entities::OrganizationTagCategory
      end

      desc '标签类别对应标签'
      get :tags do
        @organization_tags = OrganizationTag.where(organization_tag_category_id: params[:id])

        present @organization_tags, with: Entities::OrganizationTag
      end

      desc '新增标签'
      params do
        optional :name, type: String, desc: '名称'
        optional :id, as: :organization_tag_category_id, type: Integer, desc: '名称'
      end
      post :tags do
        present OrganizationTag.create!(params), with: Entities::OrganizationTag
      end


    end
  end
end