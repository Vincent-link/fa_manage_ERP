class VerificationApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':user_id' do
        before do
          @user = User.find(params[:user_id])
        end
        desc '我发起的'
        params do
          optional :status, type: Boolean, desc: '状态', values: [true, false]
        end
        get :sponsored do
          sponsored_verifications = Verification.where(status: params[:status], sponsor: params[:user_id])
          present sponsored_verifications, with: Entities::Verification
        end

        desc '我审核的'
        params do
          optional :status, type: Boolean, desc: '状态', values: [true, false]
        end
        get :verified do
          roles = Role.includes(:role_resources).where(role_resources: {name: 'admin_read_verification'})
          can_verify_users = UserRole.select { |e| roles.pluck(:id).include?(e.role_id) }
          # 如果有权限，则可以查看审核
          if can_verify_users != nil && can_verify_users.pluck(:user_id).include?(@user.id)
            verified_verifications = Verification.where(status: params[:status])
            present verified_verifications, with: Entities::Verification
          end
        end

        resource :verifications do
          resource ':verification_id' do
            before do
              @verification = Verification.find(params[:verification_id])
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

            desc '提交评分'
            params do
              requires :market, type: Integer, desc: "市场"
              requires :business, type: Integer, desc: "业务"
              requires :team, type: Integer, desc: "团队"
              requires :exchange, type: Integer, desc: "交易"
              requires :is_agree, type: Boolean, desc: "是否通会"
              optional :other, type: Integer, desc: "其他建议"
              requires :is_agree, type: Boolean, desc: "是否通会"
            end
            post :evaluate do
              funding_id = @verification.verifi[:funding_id]
              present Verification.verification_type_config[:bsc_evaluate][:op].call(@user, declared(params).merge(user_id: params[:user_id], funding_id: funding_id)), with: Entities::Evaluation
            end

            desc '提交问题'
            params do
              requires :desc, type: String, desc: "描述"
            end
            post :question do
              funding_id = @verification.verifi[:funding_id]
              present Verification.verification_type_config[:post_question][:op].call(@user, declared(params).merge(user_id: params[:user_id], funding_id: funding_id)), with: Entities::Question
            end

            desc '问题'
            get :questions do
              @questions = Question.all

              present @questions, with: Entities::Question
            end

            desc '评分'
            get :evaluations do
              @evaluations = Evaluation.all

              present @evaluations, with: Entities::Evaluation
            end
          end
        end
      end
    end
  end
end
