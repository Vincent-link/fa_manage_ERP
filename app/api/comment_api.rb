class CommentApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':commentable_id' do
        desc '获取comments', entity: Entities::Comment
        params do
          requires :type, type: String, desc: 'comments类型 comments/ir_reviews/newsfeeds', default: 'comments'
          optional :page, type: Integer, desc: '页数', default: 1
          optional :page_size, as: :per_page, type: Integer, desc: '页数', default: 10
        end
        get :comments do
          present Comment.where(commentable_type: configuration[:owner].classify, commentable_id: params[:commentable_id]).paginate(page: params[:page], per_page: params[:per_page]), with: Entities::Comment
        end

        desc '创建comments', entity: Entities::Comment
        params do
          requires :commentable_id, type: Integer, desc: ''
          requires :content, type: String, desc: '内容'
          requires :type, type: String, desc: 'comments类型 comments/ir_reviews/newsfeeds', default: 'comments'
        end
        post :comments do
          params[:type] = params[:type].classify
          comment = Comment.create(declared(params).merge(commentable_type: configuration[:owner].classify))
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
        comment = Comment.find(params[:id])
        comment.update(declared(params))
        present comment, with: Entities::Comment
      end
    end
  end
end