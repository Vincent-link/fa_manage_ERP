class TagCategoryApi < Grape::API
  resource :TagCategories do
    desc "获取所有标签分类"
    get do
      tag_categories = TagCategory.all
    end

    desc "增加一个tagcategory"
    post do
      tag = TagCategory.create(name: params)
    end
  end
end
