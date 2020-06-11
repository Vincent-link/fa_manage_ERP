class TagApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':id' do
        before do
          @root_category = TagCategory.find(params[:id])
        end

        desc '一级标签'
        get :tags do
          present @root_category.tags, with: Entities::OrganizationTagCategory
        end

        desc '创建一级标签'
        params do
          requires :name, type: String, desc: 'tag'
        end
        post :tags do
          @root_category.tag_list.add(params[:name])
          @root_category.save
        end

        resources :tags do
          resource ':one_level_tag_id' do
            before do
              @one_level_tag = ActsAsTaggableOn::Tag.find(params[:one_level_tag_id])
            end

            desc '修改一级标签'
            params do
              requires :name, type: String, desc: '名称'
            end
            patch do
              @one_level_tag.update(name: params[:name])
            end

            desc '删除一级标签'
            delete do
              @root_category.tag_list.remove(@one_level_tag.name)
              @root_category.save
              # 删除一级标签对应的二级标签
              @root_category.tags.map { |e| e.sub_tags.destroy }
            end

            desc '一级标签的所有二级标签'
            get :tags do
              present @one_level_tag.sub_tags, with: Entities::OrganizationTag
            end

            desc '增加二级标签'
            params do
              requires :name, type: String, desc: '名称'
            end
            post :tags do
              @one_level_tag.sub_tag_list.add(params[:name])
              @one_level_tag.save
            end

            resources :tags do
              resource ':two_level_tag_id' do
                before do
                  @two_level_tag = ActsAsTaggableOn::Tag.find(params[:two_level_tag_id])
                end

                desc '修改二级标签'
                params do
                  requires :name, type: String, desc: '名称'
                end
                patch do
                  @two_level_tag.update(name: params[:name])
                end

                desc '删除二级标签'
                delete do
                  @one_level_tag.sub_tag_list.remove(@two_level_tag.name)
                  @one_level_tag.save
                end
              end
            end
          end
        end
      end
    end
  end
end
