class CommentApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':commentable_id' do
        desc '获取comments', entity: Entities::Comment
        params do
          requires :type, type: String, desc: 'comments类型 comments/ir_reviews/newsfeeds', default: 'commnets'
        end
        get :comments do
          present Comment.where(commentable_type: configuration[:owner].classify, commentable_id: params[:commentable_id]), with: Entities::Comment
        end

        desc '创建comments', entity: Entities::Comment
        params do
          requires :content, as: :commentable_id, type: String, desc: '内容'
          requires :type, type: String, desc: 'comments类型 comments/ir_reviews/newsfeeds', default: 'commnets'
        end
        post :comments do
          params[:type] = params[:type].classify
          comment = Comment.create(declared(params))
          present comment, with: Entities::Comment
        end
      end
    end
  end

  resource :comments do
    resource ':id' do
      desc '删除comment'
      delete do
        Comment.find(params[:id]).destroy!
      end

      desc '修改comment', entity: Entities::Comment
      params do
        requires :content, type: String, desc: '内容'
      end
      patch do
        present Comment.find(params[:id]).update(declared(params)), with: Entities::Comment
      end
    end
  end
end