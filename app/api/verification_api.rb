class VerificationApi < Grape::API
  resource :verifications do

    desc '我发起的'
    params do
      # nil 表示未审核，true和false表示已审核
      optional :status, type: Boolean, desc: '状态', values: [true, false]
      optional :page, type: Integer, desc: '页数', default: 1
      optional :page_size, as: :per_page, type: Integer, desc: '页数', default: 10
    end
    get :sponsored do
      verifications = Verification.where(status: params[:status], sponsor: User.current.id).paginate(page: params[:page], per_page: params[:per_page]).order(created_at: :desc)
      present verifications, with: Entities::Verification
    end

    desc '我审核的'
    params do
      # nil 表示未审核，true和false表示已审核
      optional :status, type: Boolean, desc: '状态', values: [true, false]
      optional :page, type: Integer, desc: '页数', default: 1
      optional :page_size, as: :per_page, type: Integer, desc: '页数', default: 10
    end
    get :verified do
      # 是否有权限审核权限
      if can? :verify, Verification
        # 权限审核&&普通审核
        verifications = Verification.where(status: params[:status], verifi_type: Verification.verifi_type_resource_value)
        .or(Verification.where(user_id: User.current.id, status: params[:status], verifi_type: Verification.verifi_type_user_value)).paginate(page: params[:page], per_page: params[:per_page]).order(created_at: :desc)

        present verifications, with: Entities::Verification
      else
        # 如果没有权限审核权限，查出普通审核（bsc、邮件）
        verifications = Verification.where(user_id: User.current.id, status: params[:status], verifi_type: Verification.verifi_type_user_value).paginate(page: params[:page], per_page: params[:per_page]).order(created_at: :desc)
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
