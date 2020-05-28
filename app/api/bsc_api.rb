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

          # 项目成员会收到通知
          content = Notification.project_type_config[:bsc_started][:desc].call(@funding.company.name)
          @funding.funding_users.map {|e| Notification.create(notification_type: "project", content: content, user_id: e.user_id)}

          # 启动BSC后，投委会成员会收到对该项目的comments征集（提问）的邀请通知
          content = Notification.project_type_config[:ask_to_review][:desc].call(@funding.company.name)
          params[:investment_committee_ids].map {|e| Notification.create(notification_type: "project", content: content, user_id: e)}
        end

        desc '启动bsc投票'
        params do
          requires 'investment_committee_ids', type: Array[Integer], desc: "投委会成员id"
          requires 'conference_team_ids', type: Array[Integer], desc: "上会团队成员id"
        end
        post :start_bsc_evaluate do
          # 保存投委会和上会团队
          @funding.investment_committee_ids = params[:investment_committee_ids]
          @funding.update(conference_team_ids: params[:conference_team_ids], bsc_status: "evaluated")
          # 开启BSC投票后，相关投委成员会收到该项目的评分审核
          desc = Verification.verification_type_config[:bsc_evaluate][:desc].call(@funding.company.name)
          @funding.funding_users.map {|e| Verification.create(verification_type: "bsc_evaluate", desc: desc, user_id: e.user_id, verifi: {funding_id: @funding.id})}
        end

        desc '获取投委会', entity: Entities::UserLite
        get :investment_committee do
          @investment_committee = User.includes(:evaluations).where({evaluations: {funding_id: @funding.id}})
          present @investment_committee, with: Entities::UserLite
        end

        desc '获取上会团队', entity: Entities::UserLite
        get :team do
          @conference_team = Team.where(id: @funding.conference_team_ids)
          present @conference_team, with: Entities::UserLite
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
          opinion["投委会意见"] = @funding.investment_committee_opinion
          opinion["项目组意见"] = @funding.project_team_opinion
          present opinion, with: Grape::Presenters::Presenter
        end

        desc '更新讨论意见'
        params do
          requires :investment_committee_opinion, type: String, desc: "投委会意见"
          requires :project_team_opinion, type: String, desc: "项目组意见"
        end
        patch :opinion do
          @funding.update(declared(params))
          opinion = Hash.new
          opinion["投委会意见"] = params[:investment_committee_opinion]
          opinion["项目组意见"] = params[:project_team_opinion]
          present opinion, with: Grape::Presenters::Presenter
        end

        desc '获取评分'
        get :evaluations do
          if @funding.evaluations.count == @funding.evaluations.where.not(is_agree: nil).count
            # 反对票里面是否存在谁投了一票否决权
            if !@funding.evaluations.where(is_agree: 'no').nil? && @funding.evaluations.where(is_agree: 'no').pluck(:user_id).is_one_vote_veto?
              # 项目自动 pass，并给项目成员及管理员发送通知；
              Funding.transaction do
                @funding.update(status: 9)
                content = Notification.project_type_config[:passed][:desc].call(@funding.company.name)
                @funding.funding_users.map {|e| Notification.create(notification_type: "project", content: content, user_id: e.user_id)}
              end
            else
              result = @funding.evaluations.where(is_agree: 'yes').count - @funding.evaluations.where(is_agree: 'no').count
              case result
              when 0
                # 给项目成员及管理员发送通知；线下决策，决策后管理员到线上进行手动推进；推进后，给项目成员发通知
                content = Notification.project_type_config[:waitting][:desc].call(@funding.company.name)
                @funding.funding_users.map {|e| Notification.create(notification_type: "project", content: content, user_id: e.user_id)}

                roles = Role.includes(:role_resources).where(role_resources: {name: 'admin_read_verification'})
                can_verify_users = UserRole.select { |e| roles.pluck(:id).include?(e.role_id) }

                desc = Verification.verification_type_config[:bsc_evaluate][:desc].call(@funding.company.name)
                can_verify_users.pluck(:user_id).map {|e| Verification.create(verification_type: "bsc_evaluate", desc: desc, user_id: e.user_id, verifi: {funding_id: @funding.id})} unless can_verify_users.nil?
              when result < 0
                # 项目自动 pass，并给项目成员及管理员发送通知；
                Funding.transaction do
                  @funding.update(status: 9)
                  content = Notification.project_type_config[:passed][:desc].call(@funding.company.name)
                  @funding.funding_users.map {|e| Notification.create(notification_type: "project", content: content, user_id: e.user_id)}
                end
              when result > 0
                # 项目自动推进到Pursue，并给项目成员及管理员发送通知；
                Funding.transaction do
                  @funding.update(status: 3)
                  content = Notification.project_type_config[:pursued][:desc].call(@funding.company.name)
                  @funding.funding_users.map {|e| Notification.create(notification_type: "project", content: content, user_id: e.user_id)}
                end
              end
            end
          end
          type = User.current.is_admin? ? "yes" : "no"
          present @funding.evaluations, with: Entities::Evaluation, type: type
        end

        desc '提醒投票'
        post :remind_to_vote do
          content = Notification.project_type_config[:ask_to_review][:desc].call(@funding.company.name)
          @funding.evaluations.where(is_agree: nil).map {|e| Notification.create(notification_type: "project", content: content, user_id: e.user_id)}
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
          requires :question_id, type: Integer, desc: "问题id"
          requires :desc, type: String, desc: "答案内容"
        end
        post :answer do
          Answer.create(desc: params[:desc], question_id: params[:question_id])
        end

        desc '获取问题和答案'
        get :questions do
          questions_answers = Question.joins(:answers).where(funding_id: params[:funding_id])
        end

      end
    end
  end
end
