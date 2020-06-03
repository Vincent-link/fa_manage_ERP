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
      # nil为未审核， true、false为已审核
      params[:status] ||= nil
      sponsored_verifications = Verification.where(status: params[:status], sponsor: User.current.id).paginate(page: params[:page], per_page: params[:per_page])
      present sponsored_verifications, with: Entities::Verification
    end

    desc '我审核的'
    params do
      optional :status, type: Boolean, desc: '状态', values: [true, false]
      given status: ->(val) {val == true || val == false} do
        optional :page, type: Integer, desc: '页数', default: 1
        optional :page_size, as: :per_page, type: Integer, desc: '页数', default: 10
      end
    end
    get :verified do
      params[:status] ||= nil
      verification_type = [
        Verification.verification_type_config[:title_update][:value],
        Verification.verification_type_config[:ka_apply][:value],
        Verification.verification_type_config[:appointment_apply][:value]
      ]
      # 如果有查看权限，判断该管理员是否是某些项目的投委会成员
      if User.current.can_read_verification?
        # 如果管理员不在某些项目的投委会
        if User.current.evaluations.empty?
          verified_verifications = Verification.where(status: params[:status], verification_type: verification_type)
          .paginate(page: params[:page], per_page: params[:per_page])
          present verified_verifications, with: Entities::Verification
        else
          verified_verifications = Verification.where(status: params[:status], verification_type: verification_type)
          .or(User.current.verifications.where(status: params[:status], verification_type: Verification.verification_type_config[:bsc_evaluate][:value])).paginate(page: params[:page], per_page: params[:per_page])

          present verified_verifications, with: Entities::Verification
        end
      else
        # 如果不是管理员，判断是不是投资委员会成员，默认投委会成员都是有权限审核被邀请审核的项目
        verified_verifications = User.current.verifications.where(status: params[:status], verification_type: Verification.verification_type_config[:bsc_evaluate][:value]).paginate(page: params[:page], per_page: params[:per_page])
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

          Verification.verification_type_config[@verification.verification_type.to_sym][:op].call(@verification) if params[:status]
        end
      end
    end

  end
end
