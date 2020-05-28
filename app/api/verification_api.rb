class VerificationApi < Grape::API
  resource :verifications do

    desc '我发起的'
    params do
      optional :status, type: Boolean, desc: '状态', values: [true, false]
    end
    get :sponsored do
      sponsored_verifications = Verification.where(status: params[:status], sponsor: User.current.id)
      present sponsored_verifications, with: Entities::Verification
    end

    desc '我审核的'
    params do
      optional :status, type: Boolean, desc: '状态', values: [true, false]
    end
    get :verified do
      roles = Role.includes(:role_resources).where(role_resources: {name: 'admin_read_verification'})
      can_verify_users = UserRole.select { |e| roles.pluck(:id).include?(e.role_id) }
      # 如果有查看权限，判断该管理员是否是某些项目的投委会成员
      if can_verify_users != nil && can_verify_users.pluck(:user_id).include?(User.current.id)
        # 如果管理员不在某些项目的投委会
        if Evaluation.find_by(user_id: User.current.id).nil?
          verified_verifications = Verification.where(status: params[:status], verification_type: ["title_update", "ka_apply", "appointment_apply"])
          present verified_verifications, with: Entities::Verification
        else
          # funding_id = Evaluation.find_by(user_id: User.current.id).funding_id
          verified_verifications = User.current.verifications.where(status: params[:status], verification_type: "bsc_evaluate")
          present verified_verifications, with: Entities::Verification
        end
      else
        # 如果不是管理员，判断是不是投资委员会成员，默认投委会成员都是有权限查看被邀请查看的项目
        # funding_id = Evaluation.find_by(user_id: User.current.id).funding_id
        verified_verifications = User.current.verifications.where(status: params[:status], verification_type: "bsc_evaluate")
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
            optional :rejection_reseaon, type: String, desc: "拒绝理由"
        end
      end
      patch :verify do
        Verification.transaction do
          @verification.update!(status: params[:status], rejection_reason: params[:rejection_reseaon])

          Verification.verification_type_config[@verification.verification_type.to_sym][:op].call(@user, @verification) if params[:status]
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
        optional :other, type: Integer, desc: "其他建议"
      end
      post :evaluate do
        funding_id = @verification.verifi["funding_id"]
        evaluation = Verification.verification_type_config[:bsc_evaluate][:op].call(User.current, declared(params).merge(user_id: User.current.id, funding_id: funding_id))
        present evaluation, with: Entities::Evaluation
      end

      desc '提交问题', entity: Entities::Question
      params do
        requires :desc, type: String, desc: "描述"
      end
      post :question do
        funding_id = @verification.verifi["funding_id"]
        question = Verification.verification_type_config[:post_question][:op].call(User.current, declared(params).merge(user_id: User.current.id, funding_id: funding_id))
        present question, with: Entities::Question
      end

    end
  end
end
