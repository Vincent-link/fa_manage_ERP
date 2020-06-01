class BscApi < Grape::API
  mounted do
    resource configuration[:owner] do

      desc '删除当前用户答案', entity: Entities::Answer
      params do
        requires :answer_id, type: Integer
      end
      delete :answer do
        Answer.find(params[:answer_id]).destroy
      end

      desc '更新当前用户答案', entity: Entities::Answer
      params do
        requires :answer_id, type: Integer
        requires :desc, type: String
      end
      patch :answer do
        @answer = Answer.find(params[:answer_id])
        @answer.update(desc: params[:desc])
        present @answer, with: Entities::Answer
      end

      desc '提交当前用户答案', entity: Entities::Answer
      params do
        requires :question_id, type: Integer, desc: "问题id"
        requires :desc, type: String, desc: "答案内容"
      end
      post :answer do
        @answer = Answer.create(desc: params[:desc], question_id: params[:question_id], user_id: User.current.id)
        present @answer, with: Entities::Answer
      end

      resource ':id' do
        before do
          @funding = Funding.find(params[:id])
        end

        desc '启动bsc', entity: Entities::Bsc
        params do
          requires 'investment_committee_ids', type: Array[Integer], desc: "投委会成员id"
          requires 'conference_team_ids', type: Array[Integer], desc: "上会团队成员id"
        end
        post :start_bsc do
          # 创建投委会成员、上会团队
          @funding.investment_committee_ids = params[:investment_committee_ids]
          # params[:investment_committee_ids].map {|e| @funding.evaluations.create(user_id: e, funding_id: params[:id]) unless User.find(e).nil?}
          @funding.update(conference_team_ids: params[:conference_team_ids], bsc_status: "started")

          # 项目成员会收到通知
          content = Notification.project_type_config[:bsc_started][:desc].call(@funding.company.name)
          @funding.funding_users.map {|e| Notification.create(notification_type: "project", content: content, user_id: e.user_id)}
          # 启动BSC后，投委会成员会收到对该项目的comments征集（提问）的邀请通知
          content = Notification.project_type_config[:ask_to_review][:desc].call(@funding.company.name)
          params[:investment_committee_ids].map {|e| Notification.create(notification_type: "project", content: content, user_id: e)}

          present @funding, with: Entities::Bsc
        end

        desc '启动bsc投票', entity: Entities::Bsc
        params do
          requires 'investment_committee_ids', type: Array[Integer], desc: "投委会成员id"
          requires 'conference_team_ids', type: Array[Integer], desc: "上会团队成员id"
        end
        post :start_bsc_evaluate do
          # 保存投委会和上会团队
          @funding.investment_committee_ids = params[:investment_committee_ids]
          @funding.update(conference_team_ids: params[:conference_team_ids], bsc_status: "evaluatting")
          # 开启BSC投票后，相关投委成员会收到该项目的评分审核
          desc = Verification.verification_type_config[:bsc_evaluate][:desc].call(@funding.company.name)
          # 保持每个投委会成员对每个项目只有一条bsc评分审核
          @funding.evaluations.map {|e|
            if e.user.verifications.where(verification_type: "bsc_evaluate").where("verifi->>'funding_id' = '#{params[:id]}'").empty?
              Verification.create(verification_type: "bsc_evaluate", desc: desc, user_id: e.user_id, verifi: {funding_id: params[:id]})
            else
              e.user.verifications.first.update(desc: desc, status: nil)
            end
          }

          present @funding, with: Entities::Bsc
        end

        desc '获取投委会和上会团队'
        get :investment_committee_and_team do
          @investment_committee = User.includes(:evaluations).where({evaluations: {funding_id: @funding.id}})
          @conference_team = Team.where(id: @funding.conference_team_ids)

          opinion = Hash.new
          opinion["conference_team"] = @conference_team
          opinion["investment_committee"] = @investment_committee
          present opinion, with: Grape::Presenters::Presenter
        end

        desc '更新投委会和上会团队'
        params do
          requires :investment_committee_ids, type: Array[Integer]
          requires :conference_team_ids, type: Array[Integer]
        end
        post :investment_committee_and_team do
          @funding.investment_committee_ids = params[:investment_committee_ids]
          @funding.update(conference_team_ids: params[:conference_team_ids])
        end

        desc '获取讨论意见'
        get :opinion do
          opinion = Hash.new
          opinion["investment_committee_opinion"] = @funding.investment_committee_opinion
          opinion["project_team_opinion"] = @funding.project_team_opinion
          present opinion, with: Grape::Presenters::Presenter
        end

        desc '更新讨论意见'
        params do
          requires :investment_committee_opinion, type: String, desc: "投委会意见"
          requires :project_team_opinion, type: String, desc: "项目组意见"
        end
        post :opinion do
          @funding.update(declared(params))
          opinion = Hash.new
          opinion["投委会意见"] = params[:investment_committee_opinion]
          opinion["项目组意见"] = params[:project_team_opinion]
          present opinion, with: Grape::Presenters::Presenter
        end

        desc '获取评分'
        get :evaluations do


          type = User.current.is_admin? ? "yes" : "no"
          present @funding.evaluations, with: Entities::Evaluation, type: type
        end

        desc '提醒投票'
        post :remind_to_vote do
          # 判断当前用户是否是管理员
          if User.current.is_admin?
            content = Notification.project_type_config[:ask_to_review][:desc].call(@funding.company.name)
            @funding.evaluations.where(is_agree: nil).map {|e| Notification.create(notification_type: "project", content: content, user_id: e.user_id)}
          else
            present "没有权限"
          end
        end

        desc '获取问题和答案', entity: Entities::Question
        get :questions do
          questions = Question.where(funding_id: params[:id])
          present questions, with: Entities::Question
        end

        # 通知、审核里的提问
        desc '提交问题', entity: Entities::Question
        params do
          requires :desc, type: String, desc: "描述"
        end
        post :question do
          question = Verification.verification_type_config[:post_question][:op].call(declared(params).merge(funding_id: params[:id]))
          present question, with: Entities::Question
        end

      end
    end
  end
end
