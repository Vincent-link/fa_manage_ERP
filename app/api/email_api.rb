class EmailApi < Grape::API
  helpers do
    def auth_email_template(params)
      raise '模板选择错误' unless Email.emailable_type_value_code(params[:emailable_type], :email_template).include? params[:email_template]
    end
  end
  resource :emails do
    desc '获取邮件默认内容', entity: Entities::EmailMsg
    params do
      requires :emailable_id, type: Integer, desc: '对应功能id，如项目id等'
      requires :emailable_type, type: String, desc: "对应功能类型#{Email.emailable_type_id_name}", values: Email.emailable_type_values
      requires :email_template, type: Integer, desc: "模板id#{Email.email_template_id_name}", values: Email.email_template_values
      requires :signature_template, type: Integer, desc: "签名模板id#{Email.signature_template_id_name}", values: Email.signature_template_values
      optional :from_id, type: Integer, desc: '发件人id'
    end

    get 'email_msg' do
      result = {}
      auth_email_template(params)
      emailable = params[:emailable_type].constantize.find(params[:emailable_id])
      if params[:from_id].present?
        from = User.find params[:from_id]
      else
        from = current_user
      end
      [:title, :greeting, :description].each do |ins|
        result[ins] = Email.email_template_value_code(params[:email_template], ins).first.call(emailable)
      end
      result = result.merge(signature: Email.signature_template_value_code(params[:signature_template], :signature).first.call(from))
      present result, with: Entities::EmailMsg
    end

    desc '创建邮件', entity: Entities::EmailLite
    params do
      requires :emailable_id, type: Integer, desc: '对应功能id，如项目id等'
      requires :emailable_type, type: String, desc: "对应功能类型#{Email.emailable_type_id_name}", values: Email.emailable_type_values
      requires :email_template, type: Integer, desc: "模板id#{Email.email_template_id_name}", values: Email.email_template_values
      requires :signature_template, type: Integer, desc: "签名模板id#{Email.signature_template_id_name}", values: Email.signature_template_values
      optional :title, type: String, desc: '标题'
      optional :description, type: String, desc: '正文'
      optional :greeting, type: String, desc: '敬语'
      optional :signature, type: String, desc: '签名'
      optional :from_id, type: Integer, desc: '发件人id'
      requires :tos, type: Array[JSON], desc: '收件人' do
        requires :id, type: Integer, desc: '收件人id'
        requires :type, type: String, desc: '收件人类型，投资人: member', values: ['member']
      end
      optional :ccs, type: Array[JSON], desc: '抄送人' do
        optional :id, type: Integer, desc: '抄送人id'
        optional :type, type: String, desc: '抄送人类型，系统用户: user', values: ['user']
        given id: -> (val) { val.nil? } do
          requires :email, type: String, desc: '邮箱'
        end
      end
      optional :files, type: Array[JSON], desc: '附件' do
        requires :blob_id, type: Integer, desc: '附件id'
        requires :file_kind, type: Integer, desc: "附件类型#{EmailBlob.file_kind_id_name}", values: EmailBlob.file_kind_values
      end
    end

    post do
      if params[:from_id].present?
        from = User.find params[:from_id]
      else
        from = current_user
      end
      params[:user_id] = current_user.id
      emailable = params[:emailable_type].constantize.find(params[:emailable_id])
      email = emailable.emails.create!(params.slice(:title, :description, :greeting, :user_id, :email_template, :from_id, :signature_template, :signature))
      email.change_receiver(params)
      email.change_blob(params) if params[:files].present?
      present email, with: Entities::EmailLite
    end

    desc '邮件列表', entity: Entities::EmailBaseInfo
    params do
      requires :emailable_id, type: Integer, desc: '对应功能id，如项目id等'
      requires :emailable_type, type: String, desc: "对应功能类型#{Email.emailable_type_id_name}", values: Email.emailable_type_values
      optional :push_status, type: Boolean, desc: '已推送：true， 未推送：false'
    end

    get do
      emailable = params[:emailable_type].constantize.find(params[:emailable_id])
      case params[:emailable_type]
      when "Funding"
        if params[:push_status]
          emails = emailable.emails.where(status: Email.status_success_value)
        else
          emails = emailable.emails.where(user_id: current_user.id).where.not(status: Email.status_success_value)
        end
      end
      present emails, with: Entities::EmailBaseInfo
    end

    resource ':id' do
      before do
        @email = Email.find params[:id]
      end

      desc '编辑邮件', entity: Entities::EmailLite
      params do
        requires :signature_template, type: Integer, desc: "签名模板id#{Email.signature_template_id_name}", values: Email.signature_template_values
        optional :title, type: String, desc: '标题'
        optional :description, type: String, desc: '正文'
        optional :greeting, type: String, desc: '敬语'
        optional :signature, type: String, desc: '签名'
        requires :tos, type: Array[JSON], desc: '收件人' do
          requires :id, type: Integer, desc: '收件人id'
          requires :type, type: String, desc: '收件人类型，投资人: member', values: ['member']
        end
        optional :ccs, type: Array[JSON], desc: '抄送人' do
          optional :id, type: Integer, desc: '抄送人id'
          optional :type, type: String, desc: '抄送人类型，系统用户: user', values: ['user']
          given id: -> (val) { val.nil? } do
            requires :email, type: String, desc: '邮箱'
          end
        end
        optional :files, type: Array[JSON], desc: '附件' do
          requires :blob_id, type: Integer, desc: '附件id'
          requires :file_kind, type: Integer, desc: "附件类型#{EmailBlob.file_kind_id_name}", values: EmailBlob.file_kind_values
        end
      end

      patch do
        @email.update!(params.slice(:signature_template, :signature, :title, :description, :greeting, :signature))
        @email.change_receiver(params)
        @email.change_blob(params) if params[:files].present?
        present @email, with: Entities::EmailLite
      end

      desc '获取邮件详情', entity: Entities::Email
      params do
      end

      get do
        present @email, with: Entities::Email
      end

      desc '删除邮件', entity: Entities::EmailLite
      params do
      end

      delete do
        @email.destroy
        present @email, with: Entities::EmailLite
      end

      desc '提交审核', entity: Entities::EmailLite
      params do
      end

      post 'verification' do
        @email.gen_verification
        present @email, with: Entities::EmailLite
      end

      desc '测试推送', entity: Entities::EmailLite
      params do
        requires :user_ids, type: Array[Integer], desc: '测试推送收件人id'
        optional :tos, type: Array[JSON], desc: '收件人' do
          optional :relation_id, type: Integer, desc: '收件人唯一标识id'
          optional :person_title, type: String, desc: '称谓'
        end
      end

      post 'test_push' do
        @email.auth_test_user(params)
        @email.test_push_email(params)
        present @email, with: Entities::EmailLite
      end

      desc '提交推送', entity: Entities::EmailLite
      params do
        optional :tos, type: Array[JSON], desc: '收件人' do
          optional :relation_id, type: Integer, desc: '收件人唯一标识id'
          optional :person_title, type: String, desc: '称谓'
        end
      end

      post 'official_push' do
        raise '不要用别人的邮箱发邮件' unless (@email.from_id || @email.user_id) == current_user.id
        if params[:tos].present?
          email_to_groups = @email.email_to_groups
          params[:tos].each do |to|
            email_to_groups.find(to[:relation_id]).update!(person_title: to[:person_title])
          end
        end
        @email.official_push_email
        present @email, with: Entities::EmailLite
      end
    end
  end
end
