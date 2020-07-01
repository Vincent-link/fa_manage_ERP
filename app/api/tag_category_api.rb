class TagCategoryApi < Grape::API
  resources :tag_categories do
    desc '标签类别'
    get do
      present TagCategory.all, with: Entities::TagCategory
    end

    # desc '创建标签类别'
    # params do
    #   requires :name, type: String, desc: 'tag类别'
    # end
    # post do
    #   TagCategory.create(declared(params))
    # end

    resource ':id' do
      before do
        @tag_category = TagCategory.find(params[:id])
      end

      # desc '删除标签类别'
      # delete do
      #   # 删除子标签
      #   sub_tag_ids = @tag_category.tags.map{|e| e.sub_tags.pluck(:tag_id)}
      #   @tag_category.tags.map{|e| e.sub_tags.destroy_all}
      #   sub_tag_ids = sub_tag_ids.flatten
      #
      #   # 删除标签
      #   tag_ids = @tag_category.tags.pluck(:tag_id) + sub_tag_ids
      #   @tag_category.tags.destroy_all
      #   ActsAsTaggableOn::Tag.where(id: tag_ids).destroy_all
      #
      #   @tag_category.destroy
      # end

      # desc '编辑标签类别'
      # params do
      #   requires :name, type: String, desc: 'tag类别'
      # end
      # patch do
      #   @tag_category.update(name: params[:name])
      # end
    end
  end

  mount TagApi, with: {owner: 'tag_categories'}
end
