class VerificationApi < Grape::API
  resource :verifications do

    desc '我发起的'
    params do
      optional :status, type: Boolean, desc: '状态', values: [true, false]
      optional :page, type: Integer, desc: '页数', default: 1
      optional :page_size, as: :per_page, type: Integer, desc: '页数', default: 10
    end
    get :sponsored do
      # nil为未审核， true、false为已审核
      params[:status] ||= nil
      verifications = Verification.where(status: params[:status], sponsor: User.current.id).paginate(page: params[:page], per_page: params[:per_page])
      present verifications, with: Entities::Verification
    end

    desc '我审核的'
    params do
      optional :status, type: Boolean, desc: '状态', values: [true, false]
      optional :page, type: Integer, desc: '页数', default: 1
      optional :page_size, as: :per_page, type: Integer, desc: '页数', default: 10
    end
    get :verified do
      params[:status] ||= nil
      super_verification_type = [
        Verification.verification_type_config[:title_update][:value],
        Verification.verification_type_config[:ka_apply][:value],
        Verification.verification_type_config[:appointment_apply][:value]
      ]
      general_verification_type = [
        Verification.verification_type_config[:bsc_evaluate][:value],
        Verification.verification_type_config[:email][:value],
      ]
      # 是否有权限审核权限
      if can? :verify, Verification
        # 权限审核&&普通审核
        verifications = Verification.where(status: params[:status], verification_type: super_verification_type)
        .or(User.current.verifications.where(status: params[:status], verification_type: general_verification_type)).paginate(page: params[:page], per_page: params[:per_page])

        present verifications, with: Entities::Verification
      else
        # 如果没有权限审核权限，查出普通审核（bsc、邮件）
        verifications = User.current.verifications.where(status: params[:status], verification_type: general_verification_type).paginate(page: params[:page], per_page: params[:per_page])
        present verifications, with: Entities::Verification
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

          Verification.verification_type_config[@verification.verification_type.to_sym][:op].call(@verification) if params[:status]
        end
      end
    end

  end
end
