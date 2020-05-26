class BscApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':id' do
        before do
          @funding = Funding.find(params[:id])
        end

        desc '启动bsc'
        params do
          requires 'investment_committee_ids', type: Array[Integer], desc: "投委会成员id"
          requires 'conference_team_ids', type: Array[Integer], desc: "上会团队成员id"
        end
        post :start_bsc do
          params[:investment_committee_ids].map {|e| @funding.evaluations.create(user_id: e)}
          @funding.update(conference_team_ids: params[:conference_team_ids], bsc_status: "started")

          # 启动BSC后，投委会成员会收到对该项目的comments征集（提问）的邀请通知
          content = Notification.project_type_config[:pass][:desc].call(user_title_before, @user_title.name)
          Notification.create(notification_type: "project", content:)
        end

        desc '启动bsc投票'
        params do
          requires 'investment_committee_ids', type: Array[Integer], desc: "投委会成员id"
          requires 'conference_team_ids', type: Array[Integer], desc: "上会团队成员id"
        end
        post :start_bsc_evaluate do
          # 保存投委会和上会团队
          # 状态转换
          # 开启BSC投票后，相关投委成员会收到该项目的评分审核
        end

        desc '获取投委会和上会团队'
        get :investment_committee_and_team do
          User.includes(:evaluations).where(funding_id: @funding.id)
        end

        desc '更新投委会和上会团队'
        params do
          requires :investment_committee_ids, type: Array[Integer]
          requires :conference_team_ids, type: Array[Integer]
        end
        patch :investment_committee_and_team do
          User.includes(:evaluations).where(funding_id: @funding.id)
        end

        desc '讨论意见'
        get :opinion do
          @funding.investment_committee_opinion
        end

        desc '获取评分'
        get :evaluations do
          evaluations = Evaluation.where(funding_id: params["id"])
          # 判断投票结果
        end

        desc '提醒投票'
        post :remind_to_vote do
          # 创建通知
        end

        desc '删除当前用户答案'
        params do
          requires :answer_id, type: Integer
        end
        delete :answer do
          Answer.find(params[:answer_id]).destroy
        end

        desc '更新当前用户答案'
        params do
          requires :answer_id, type: Integer
          requires :desc, type: String
        end
        patch :answer do
          Answer.find(params[:answer_id]).update(desc: params[:desc])
        end

        desc '提交当前用户答案'
        params do
          requires :desc, type: String
        end
        post :answer do
          Answer.create
        end

        desc '获取问题和答案'
        get :questions do
          questions_answers = Question.joins(:answers).where(funding_id: params[:funding_id])
        end

      end
    end
  end
end
