class TagCategoryApi < Grape::API
  resources :tag_categories do
    desc '标签类别'
    get do
      present TagCategory.all, with: Entities::UserLite
    end

    desc '创建标签类别'
    params do
      requires :name, type: String, desc: 'tag类别'
    end
    post do
      TagCategory.create(declared(params))
    end

    resource ':id' do
      before do
        @tag_category = TagCategory.find(params[:id])
      end

      desc '删除标签类别'
      delete do
        @tag_category.destroy
      end

      desc '编辑标签类别'
      params do
        requires :name, type: String, desc: 'tag类别'
      end
      patch do
        @tag_category.update(name: params[:name])
      end
    end
  end

  mount TagApi, with: {owner: 'tag_categories'}
end
