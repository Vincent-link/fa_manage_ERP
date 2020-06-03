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
        post "bsc/start_bsc" do
          # 创建投委会成员、上会团队
          @funding.investment_committee_ids = params[:investment_committee_ids]
          @funding.update(conference_team_ids: params[:conference_team_ids], bsc_status: Funding.bsc_status_config[:started][:value])
          # 项目成员会收到通知
          content = Notification.project_type_config[:bsc_started][:desc].call(@funding.name)
          binding.pry
          @funding.funding_users.map {|e| Notification.create(notification_type: Notification.notification_type_config[:project][:desc], content: content, user_id: e.user_id, is_read: false)}
          # 启动BSC后，投委会成员会收到对该项目的comments征集（提问）的邀请通知
          content = Notification.project_type_config[:ask_to_review][:desc].call(@funding.name)
          params[:investment_committee_ids].map {|e| Notification.create(notification_type: Notification.notification_type_config[:project][:desc], content: content, user_id: e, is_read: false)}

          present true
        end

        desc '启动bsc投票'
        params do
          requires 'investment_committee_ids', type: Array[Integer], desc: "投委会成员id"
          requires 'conference_team_ids', type: Array[Integer], desc: "上会团队成员id"
        end
        post "bsc/start_bsc_evaluate" do
          # 保存投委会和上会团队
          @funding.investment_committee_ids = params[:investment_committee_ids]
          @funding.update(conference_team_ids: params[:conference_team_ids], bsc_status: Funding.bsc_status_config[:evaluatting][:value])
          # 开启BSC投票后，相关投委成员会收到该项目的评分审核
          desc = Verification.verification_type_config[:bsc_evaluate][:desc].call(@funding.name)
          # 保持每个投委会成员对应的bsc评分项目只有一条bsc评分审核
          @funding.evaluations.map {|e|
            if e.user.verifications.where(verification_type: Verification.verification_type_config[:bsc_evaluate][:value]).where("verifi->>'funding_id' = '#{params[:id]}'").empty?
              Verification.create(verification_type: Verification.verification_type_config[:bsc_evaluate][:value], desc: desc, user_id: e.user_id, verifi: {funding_id: params[:id]})
            else
              e.user.verifications.first.update(desc: desc, status: nil)
            end
          }

          present true
        end

        desc '获取投委会和上会团队'
        get "bsc/investment_committee_and_team" do
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
        post "bsc/investment_committee_and_team" do
          @funding.investment_committee_ids = params[:investment_committee_ids]
          @funding.update(conference_team_ids: params[:conference_team_ids])
        end

        desc '获取讨论意见'
        get "bsc/opinion" do
          opinion = Hash.new
          opinion["investment_committee_opinion"] = @funding.investment_committee_opinion
          opinion["project_team_opinion"] = @funding.project_team_opinion
          present opinion
        end

        desc '更新讨论意见'
        params do
          requires :investment_committee_opinion, type: String, desc: "投委会意见"
          requires :project_team_opinion, type: String, desc: "项目组意见"
        end
        post "bsc/opinion" do
          @funding.update(declared(params))
        end

        desc '获取评分'
        get "bsc/evaluations" do
          evaluations = @funding.evaluations.select {|e| !e.is_agree.nil?}
          type = User.current.is_admin? ? "yes" : "no"
          present evaluations, with: Entities::Evaluation, type: type
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
        post "bsc/evaluations" do
          @verifications = Verification.where(user_id: User.current, verification_type: Verification.verification_type_config[:bsc_evaluate][:value]).where("verifi->>'funding_id' = '#{params[:id]}'")
          Verification.transaction do
            evaluation = Verification.verification_type_config[:bsc_evaluate][:op].call(declared(params).merge(funding_id: params[:id]))
            @verifications.first.update(status: true) unless @verifications.empty?
          end

          @funding.is_pass_for_bsc?
        end

        desc '提醒投票'
        post "bsc/remind_to_vote" do
          # 判断当前用户是否是管理员
          if can? :remind, "to_vote"
            content = Notification.project_type_config[:ask_to_review][:desc].call(@funding.name)
            @funding.evaluations.where(is_agree: nil).map {|e| Notification.create(notification_type: Notification.notification_type_config[:project][:desc], content: content, user_id: e.user_id, is_read: false)}
          else
            raise CanCan::AccessDenied
          end
        end

        desc '获取问题和答案', entity: Entities::Question
        get "bsc/questions" do
          questions = Question.where(funding_id: params[:id])
          present questions, with: Entities::Question
        end

        # 通知、审核里的提问
        desc '提交问题'
        params do
          requires :desc, type: String, desc: "描述"
        end
        post "bsc/questions" do
          question = Verification.verification_type_config[:post_question][:op].call(declared(params).merge(funding_id: params[:id]))
        end

        desc '删除当前用户答案'
        params do
          requires :answer_id, type: Integer
        end
        delete "bsc/answers" do
          Answer.find(params[:answer_id]).destroy
        end

        desc '更新当前用户答案'
        params do
          requires :answer_id, type: Integer
          requires :desc, type: String
        end
        patch "bsc/answers" do
          @answer = Answer.find(params[:answer_id])
          @answer.update(desc: params[:desc])
        end

        desc '提交当前用户答案'
        params do
          requires :desc, type: String, desc: "答案内容"
          requires :question_id, type: Integer, desc: "问题id"
        end
        post "bsc/answers" do
          @answer = Answer.create(desc: params[:desc], question_id: params[:question_id], user_id: User.current.id)
        end

      end
    end
  end
end
