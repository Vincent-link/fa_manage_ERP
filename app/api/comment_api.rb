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
          present params[:type].classify.constantize.where(commentable_type: configuration[:owner].classify, commentable_id: params[:commentable_id]).order(updated_at: :desc).paginate(page: params[:page], per_page: params[:per_page]), with: Entities::Comment
        end

        desc '创建comments', entity: Entities::Comment
        params do
          requires :commentable_id, type: Integer, desc: ''
          requires :content, type: String, desc: '内容'
          requires :type, type: String, desc: 'comments类型 comments/ir_reviews/newsfeeds', values: ["comments", "ir_reviews", "newsfeeds"]
          optional :relate_user_ids, type: Array[Integer], desc: '参与人员'
        end
        post :comments do
          params[:type] = params[:type].classify
          comment = Comment.create(declared(params).merge(commentable_type: configuration[:owner].classify))

          if params[:type] == "IrReview" && params[:commentable_id].present?
            organization = Organization.find(params[:commentable_id])
            organization.ir_reviews.create(user_id: User.current.id, content: params[:summary]) if organization.present?

            content = Notification.notification_type_config[:ir_review][:content].call(User.current.name, organization.name) if organization.name.present?
            Notification.create(notification_type: Notification.notification_type_value("ir_review"), content: content, is_read: false, notice: {organization_id: organization.id}) if content.present?
          end

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
        optional :relate_user_ids, type: Array[Integer], desc: '参与人员'
      end
      patch do
        comment = Comment.find(params[:id])
        comment.update(declared(params))
        present comment, with: Entities::Comment
      end
    end
  end
end
