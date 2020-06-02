class OrganizationTagCategoryApi < Grape::API
  resource :organization_tag_categories do

    desc '所有标签类别', entity: Entities::OrganizationTagCategory
    get do
      present OrganizationTagCategory.all, with: Entities::OrganizationTagCategory
    end

    desc "新增标签类别", entity: Entities::OrganizationTagCategory
    params do
      optional :name, type: String, desc: '名称'
    end
    post do
      present OrganizationTagCategory.create!(declared(params)), with: Entities::OrganizationTagCategory
    end

    resources ':id' do
      before do
        @organization_tag_category = OrganizationTagCategory.find(params[:id])
      end

      desc '删除标签类别'
      delete do
        @organization_tag_category.destroy!
      end

      desc '更新标签类别', entity: Entities::OrganizationTagCategory
      params do
        requires :name, type: String, desc: '名称'
      end
      patch do
        @organization_tag_category.update(declared(params))
        present @organization_tag_category, with: Entities::OrganizationTagCategory
      end
    end
  end

  mount OrganizationTagApi, with: {owner: 'organization_tag_categories'}
end
