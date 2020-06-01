class VerificationApi < Grape::API
  resource :verifications do

    desc '我发起的'
    params do
      optional :status, type: Boolean, desc: '状态', values: [true, false]
      given status: ->(val) {val == true || val == false} do
        optional :page, type: Integer, desc: '页数', default: 1
        optional :page_size, as: :per_page, type: Integer, desc: '页数', default: 10
      end
    end
    get :sponsored do
      params[:status] ||= nil
      sponsored_verifications = Verification.where(status: params[:status], sponsor: User.current.id).paginate(page: params[:page], per_page: params[:per_page])
      present sponsored_verifications, with: Entities::Verification
    end

    desc '我审核的'
    params do
      optional :status, type: Boolean, desc: '状态', values: [true, false]
      given status: ->(val) { val == true} do
        optional :page, type: Integer, desc: '页数', default: 1
        optional :page_size, as: :per_page, type: Integer, desc: '页数', default: 10
      end
    end
    get :verified do
      params[:status] ||= nil
      # 如果有查看权限，判断该管理员是否是某些项目的投委会成员
      if User.current.can_read_verification?
        # 如果管理员不在某些项目的投委会
        if User.current.evaluations.empty?
          verified_verifications = Verification.where(status: params[:status], verification_type: ["title_update", "ka_apply", "appointment_apply"])
          .paginate(page: params[:page], per_page: params[:per_page])
          present verified_verifications, with: Entities::Verification
        else
          verified_verifications = Verification.where(status: params[:status], verification_type: ["title_update", "ka_apply", "appointment_apply"])
          .or(User.current.verifications.where(status: params[:status], verification_type: "bsc_evaluate")).paginate(page: params[:page], per_page: params[:per_page])

          present verified_verifications, with: Entities::Verification
        end
      else
        # 如果不是管理员，判断是不是投资委员会成员，默认投委会成员都是有权限审核被邀请审核的项目
        verified_verifications = User.current.verifications.where(status: params[:status], verification_type: "bsc_evaluate").paginate(page: params[:page], per_page: params[:per_page])
        present verified_verifications, with: Entities::Verification
      end

    end

    resource ':id' do
      before do
        @verification = Verification.find(params[:id])
      end

      desc '非bsc提交审核'
      params do
        requires :status, type: Boolean, values: [true, false], desc: "审核结果"
        given status: ->(val) { val == false } do
            requires :rejection_reseaon, type: String, desc: "拒绝理由"
        end
      end
      patch :verify do
        Verification.transaction do
          @verification.update!(status: params[:status], rejection_reason: params[:rejection_reseaon])

          Verification.verification_type_config[@verification.verification_type.to_sym][:op].call(@verification) if params[:status]
        end
        present @verification, with: Entities::Verification
      end

      desc '提交评分', entity: Entities::Evaluation
      params do
        requires :market, type: Integer, desc: "市场"
        requires :business, type: Integer, desc: "业务"
        requires :team, type: Integer, desc: "团队"
        requires :exchange, type: Integer, desc: "交易"
        requires :is_agree, type: String, desc: "是否过会", values: ["yes", "no", "fence"]
        optional :other, type: String, desc: "其他建议"
      end
      post :evaluate do
        funding_id = @verification.verifi["funding_id"]
        @funding = Funding.find(funding_id)

        Verification.transaction do
          evaluation = Verification.verification_type_config[:bsc_evaluate][:op].call(declared(params).merge(funding_id: funding_id))
          @verification.update(status: true)
          present evaluation, with: Entities::Evaluation
        end

        if @funding.evaluations.count == @funding.evaluations.where.not(is_agree: nil).count && @funding.bsc_status == "evaluatting"
          # 找出管理员
          managers = User.select {|e| e.is_admin?}
          # 反对票里面是否存在谁投了一票否决权
          evaluations = @funding.evaluations.where(is_agree: 'no').select {|e| e.user.is_one_vote_veto?}
          if !evaluations.empty?
            # 项目自动 pass，并给项目成员及管理员发送通知；
            Funding.transaction do
              @funding.update(status: 9, bsc_status: "finished")
              content = Notification.project_type_config[:passed][:desc].call(@funding.company.name)
              funding_users = @funding.funding_users.map {|e| User.find(e.user_id)}

              (managers+funding_users).uniq.map { |e| Notification.create(notification_type: "project", content: content, user_id: e.id) }
            end
          else
            result = @funding.evaluations.where(is_agree: 'yes').count - @funding.evaluations.where(is_agree: 'no').count
            case result
            when 0
              # 给项目成员发通知
              content = Notification.project_type_config[:waitting][:desc].call(@funding.company.name)
              @funding.funding_users.map {|e| Notification.create(notification_type: "project", content: content, user_id: e.user_id)}

              roles = Role.includes(:role_resources).where(role_resources: {name: 'admin_read_verification'})
              can_verify_users = UserRole.select { |e| roles.pluck(:id).include?(e.role_id) }
              #给管理员发审核
              desc = Verification.verification_type_config[:bsc_evaluate][:desc].call(@funding.company.name)
              can_verify_users.pluck(:user_id).map {|e| Verification.create(verification_type: "bsc_evaluate", desc: desc, user_id: e.user_id, verifi: {funding_id: @funding.id})} unless can_verify_users.nil?
            when -Float::INFINITY...0
              # 项目自动 pass，并给项目成员及管理员发送通知；
              Funding.transaction do
                @funding.update(status: 9, bsc_status: "finished")
                content = Notification.project_type_config[:passed][:desc].call(@funding.company.name)
                funding_users = @funding.funding_users.map {|e| User.find(e.user_id)}

                (managers+funding_users).uniq.map { |e| Notification.create(notification_type: "project", content: content, user_id: e.id) }
              end
            when 0..Float::INFINITY
              # 项目自动推进到Pursue，并给项目成员及管理员发送通知；
              Funding.transaction do
                @funding.update(status: 3, bsc_status: "finished")
                content = Notification.project_type_config[:pursued][:desc].call(@funding.company.name)
                funding_users = @funding.funding_users.map {|e| User.find(e.user_id)}

                (managers+funding_users).uniq.map { |e| Notification.create(notification_type: "project", content: content, user_id: e.id) }
              end
            end
          end
        end

      end

    end
  end
end
