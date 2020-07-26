class TagApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':id' do
        before do
          @tag_category = TagCategory.find(params[:id])
        end

        desc '标签'
        get do
          present @tag_category.tags.order(created_at: :desc), with: Entities::Tag
        end

        desc '创建标签'
        params do
          requires :name, type: String, desc: '标签'
        end
        post do
          @tag_category.tag_list.add(params[:name])
          @tag_category.save
        end
      end
    end
  end

  resources :tags do
    resource ':tag_id' do
      before do
        @one_level_tag = ActsAsTaggableOn::Tag.find(params[:tag_id])
      end

      desc '修改标签'
      params do
        requires :name, type: String, desc: '名称'
      end
      patch do
        @one_level_tag.update(declared(params))
      end

      desc '删除标签'
      delete do
        # 删除子标签
        sub_tag_ids = @one_level_tag.sub_tags.pluck(:tag_id)
        @one_level_tag.sub_tags.destroy_all
        ActsAsTaggableOn::Tag.where(id: sub_tag_ids).destroy_all

        # 删除标签
        ActsAsTaggableOn::Tagging.where(tag_id: @one_level_tag.id).destroy_all
        @one_level_tag.destroy
      end

      # desc '一级标签的所有二级标签'
      # get :tags do
      #   present @one_level_tag.sub_tags.order(created_at: :desc), with: Entities::Tag
      # end
      #
      # desc '增加二级标签'
      # params do
      #   requires :name, type: String, desc: '名称'
      # end
      # post :tags do
      #   @one_level_tag.sub_tag_list.add(params[:name])
      #   @one_level_tag.save
      #
      #   # 同步更新二级标签适用范围
      #   @one_level_tag.sub_tag_ids.map {|e| ActsAsTaggableOn::Tag.find(e).update(coverage: @one_level_tag.coverage) if ActsAsTaggableOn::Tag.find(e).coverage.nil? || ActsAsTaggableOn::Tag.find(e).coverage != @one_level_tag.coverage} if @one_level_tag.sub_tag_ids.present?
      #   true
      # end
    end

    # resource ':two_level_tag_id' do
    #   before do
    #     @two_level_tag = ActsAsTaggableOn::Tag.find(params[:two_level_tag_id])
    #   end
    #
    #   desc '修改二级标签'
    #   params do
    #     requires :name, type: String, desc: '名称'
    #   end
    #   patch do
    #     @two_level_tag.update(name: params[:name])
    #   end
    #
    #   desc '删除二级标签'
    #   delete do
    #     ActsAsTaggableOn::Tagging.where(tag_id: @two_level_tag.id).destroy_all
    #     @two_level_tag.destroy
    #   end
    # end
  end
end
