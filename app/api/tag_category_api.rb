class TagCategoryApi < Grape::API
  resources :tag_categories do
    before do
      @root_category = TagCategory.find_or_create_by(name: params[:tag_category])
    end

    desc '标签类别'
    params do
      requires :tag_category, type: String, desc: 'tag类别', values: ['机构标签','投资人标签', '公司标签','行业标签']
    end
    get do
      present @root_category.tags, with: Entities::OrganizationTag
    end

    desc '创建标签类别'
    params do
      requires :tag_category, type: String, desc: 'tag类别', values: ['机构标签','投资人标签', '公司标签','行业标签']
      requires :name, type: String, desc: 'tag类别'
    end
    post do
      @root_category.tag_list.add(params[:name])
      @root_category.save
    end

    resource ':id' do
      before do
        @tag_category = ActsAsTaggableOn::Tag.find(params[:id])
      end

      desc '标签类别对应标签', entity: Entities::OrganizationTag
      get do
        present @tag_category.sub_tags, with: Entities::OrganizationTag
      end

      desc '新增标签'
      params do
        requires :name, type: String, desc: 'tag类别'
      end
      post do
        @tag_category.sub_tag_list.add(params[:name])
        @tag_category.save
      end
    end
  end
end
