class VerificationApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource :id do
        desc '我发起的'
        params do
          optional :status, type: String, desc: '状态'
        end
        get :sponsored do
          sponsored_verifications = Verification.where(status: params[:status], sponsor: params[:id])
          present sponsored_verifications, with: Entities::Verification
        end

        desc '我审核的'
        params do
          optional :status, type: String, desc: '状态'
        end
        get :verified do
          sponsored_verifications = Verification.where(status: params[:status], sponsor: params[:id])
        end         

        resource :verifications do
          desc '提交审核'
          params do
            requires :status, type: Boolean, values: [true, false], desc: "审核结果" 
            given status: ->(val) { val == false } do
                requires :rejection_reseaon, type: String, desc: "拒绝理由"
            end            
          end          
          post :verify do

          end

          desc '提交评分'
          params do
            requires :market, type: Integer, desc: "市场"
            requires :business, type: Integer, desc: "业务"
            requires :team, type: Integer, desc: "团队"
            requires :exchange, type: Integer, desc: "交易"
            requires :is_agree, type: Integer, desc: "是否通会"
            optional :other, type: Integer, desc: "其他建议"
          end  
          post :evaluate do

          end

          desc '提交问题'
          params do
            requires :desc, type: String, desc: "描述"
          end  
          post :question do

          end

          desc '问题' 
          get :questions do

          end

          desc '评分' 
          get :evaluations do

          end 

        end
      end
    end
  end
end