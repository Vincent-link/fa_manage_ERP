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
          @funding.update(conference_team_ids: params[:conference_team_ids], bsc_status: Funding.bsc_status_started_value)
          # 项目成员会收到通知
          content = Notification.project_type_bsc_started_desc.call(@funding.company.name)
          @funding.funding_users.where(kind: FundingUser.kind_value(:normal_users)).map {|e| Notification.create(notification_type: Notification.notification_type_project_value, content: content, user_id: e.user_id, is_read: false, notice: {funding_id: @funding.id})}
          # 启动BSC后，投委会成员会收到对该项目的comments征集（提问）的邀请通知
          content = Notification.project_type_ask_to_review_desc.call(@funding.company.name)
          params[:investment_committee_ids].map {|e| Notification.create(notification_type: Notification.notification_type_project_value, content: content, user_id: e, is_read: false, notice: {funding_id: @funding.id})}

          # 给投委会发提问审核
          desc = Verification.verification_type_post_question_desc.call(@funding.company.name)
          @funding.evaluations.map {|e|
            verifications = Verification.where(user_id: e.user_id, verification_type: Verification.verification_type_post_question_value).where("verifi->>'funding_id' = '#{params[:id]}'")
            if verifications.empty?
              Verification.create(verification_type: Verification.verification_type_post_question_value, desc: desc, user_id: e.user_id, verifi: {funding_id: params[:id]}, verifi_type: Verification.verifi_type_user_value)
            else
              verifications.first.update(desc: desc, status: nil)
            end
          }

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
          @funding.update!(conference_team_ids: params[:conference_team_ids], bsc_status: Funding.bsc_status_evaluatting_value)
          # 开启BSC投票后，相关投委成员会收到该项目的评分审核
          desc = Verification.verification_type_bsc_evaluate_desc.call(@funding.company.name)
          # 保持每个投委会成员对应的bsc评分项目只有一条bsc评分审核
          @funding.evaluations.map {|e|
            verifications = Verification.where(user_id: e.user_id, verification_type: Verification.verification_type_bsc_evaluate_value).where("verifi->>'funding_id' = '#{params[:id]}'")
            if verifications.empty?
              Verification.create(verification_type: Verification.verification_type_bsc_evaluate_value, desc: desc, user_id: e.user_id, verifi: {funding_id: params[:id]}, verifi_type: Verification.verifi_type_user_value)
            else
              verifications.first.update(desc: desc, status: nil)
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
          @verifications = Verification.where(user_id: User.current, verification_type: Verification.verification_type_bsc_evaluate_value).where("verifi->>'funding_id' = '#{params[:id]}'")
          Verification.transaction do
            Verification.verification_type_bsc_evaluate_op.call(declared(params).merge(funding_id: params[:id]))
            @verifications.first.update!(status: true) unless @verifications.empty?
          end

          @funding.is_pass_for_bsc?
          true
        end

        desc '提醒投票'
        post "bsc/remind_to_vote" do
          # 判断当前用户是否是管理员
          if can? :remind, "to_vote"
            content = Notification.project_type_ask_to_review_desc.call(@funding.name)
<<<<<<< HEAD
            @funding.evaluations.where(is_agree: nil).map {|e| Notification.create(notification_type: Notification.notification_type_project_desc, content: content, user_id: e.user_id, is_read: false, notice: {funding_id: @funding.id})}
=======
            @funding.evaluations.where(is_agree: nil).map {|e| Notification.create(notification_type: Notification.notification_type_project_desc, content: content, user_id: e.user_id, is_read: false, notice: {funding_id: self.id})}
>>>>>>> add financing events
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
          question = Verification.verification_type_post_question_op.call(declared(params).merge(funding_id: params[:id]))
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

          content = Notification.project_type_config[:answered][:desc].call(@funding.name)
          Notification.create(notification_type: Notification.notification_type_project_value, content: content, user_id: User.current.id, is_read: false, notice: {kind: Notification.project_type_value(:answered), funding_id: @funding.id})
        end
      end
    end
  end

  resources :bscs do
    desc '所有bsc'
    params do
      optional :query, type: String, desc: "搜索名称"
      optional :bsc_status, type: Array[Integer], desc: "bsc状态"
      optional :agree_time_from, type: Date, desc: "开始日期"
      optional :agree_time_to, type: Date, desc: "结束日期"
      optional :conference_team_ids, type: Array[Integer], desc: "上会团队"
    end
    get do
      bscs = Funding.select(:id, :name, :bsc_status, :conference_team_ids, :agree_time)
      bscs = bscs.where(bsc_status: params[:bsc_status]) if params[:bsc_status].present?
      bscs = bscs.where("agree_time > ?", params[:agree_time_from]) if params[:agree_time_from].present?
      bscs = bscs.where("agree_time < ?", params[:agree_time_to]) if params[:agree_time_to].present?

      bscs = bscs.where('name like ?', "%#{params[:query]}%") if params[:query].present?
      bscs = bscs.select{|e| !(params[:conference_team_ids].map(&:to_i) & e.conference_team_ids).empty? unless e.conference_team_ids.nil?} if params[:conference_team_ids].present?

      present bscs, with: Entities::BscForIndex
    end

    desc "导出数据"
    params do
      optional :part, type: String, desc: "导出类型", values: ["投票数据", "过会数据"]
    end
    post :export do
      dir = Dir.open("public")
      Dir.mkdir("public/export") unless dir.include?("export")
      case params[:part]
      when "投票数据"
        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet
        sheet1.row(0).concat %w{序号 是否过会 上会团队 项目 投票序号 提交时间 市场（满分5星） 业务（满分5星） 团队（满分5星） 交易（满分5星） 投票表决是否过会 其他评价和建议 投票人 BSC讨论意见}
        row = 0
        Evaluation.all.map do |evaluation|
          row +=1
          result = evaluation.funding.is_pass?
          teams = evaluation.funding.conference_team.pluck(:name).join("/")
          name = evaluation.funding.name
          number = evaluation.number
          created_at = evaluation.created_at.strftime("%Y/%m/%d %H:%M")
          market = evaluation.market
          business = evaluation.business
          team = evaluation.team
          exchange = evaluation.exchange
          is_agree = evaluation.is_agree
          other = evaluation.other
          voter = evaluation.user.name
          opinion = ""
          opinion << evaluation.funding.investment_committee_opinion unless evaluation.funding.investment_committee_opinion.nil?
          opinion << evaluation.funding.project_team_opinion unless evaluation.funding.project_team_opinion.nil?
          sheet1.row(row).concat [row, result, teams, name, number, created_at, market, business, team, exchange, is_agree, other, voter, opinion]
        end
        book.write "public/export/投票数据-#{Time.now}.xls"
      when "过会数据"
        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet
        sheet1.row(0).concat %w{编号 项目名称 导出日期 来源部门 上会团队 一句话简介 所属行业 项目类型 融资轮次 融资币种 融资额 估值币种 预计本轮投后估值 过会时间 联系人 项目介绍 是否为上市/新三板公司或其拆分/控股资产}
        row = 0
        Funding.all.map do |funding|
          row +=1
          name = funding.name
          export_time = Time.now.strftime("%Y/%m/%d")
          bu = "财务顾问事业部"
          teams = funding.conference_team.pluck(:name).join("/")
          shiny_word = funding.shiny_word
          sectors = funding.company.sectors.pluck(:name).join("/")
          type = funding.category
          round = funding.round
          target_amount_currency = funding.target_amount_currency
          target_amount = funding.target_amount
          post_valuation_currency = funding.post_valuation_currency
          post_investment_valuation = funding.post_investment_valuation
          agree_time = funding.agree_time
          contacts = funding.company.contacts.pluck(:name).join("/")
          intro = funding.company.detailed_intro
          is_list = funding.is_list?
          sheet1.row(row).concat [row, name, export_time, bu, teams, shiny_word, sectors, type, round, target_amount_currency, target_amount,
            post_valuation_currency, post_investment_valuation, agree_time, contacts, intro, is_list]
        end
        book.write "public/export/过会数据-#{Time.now}.xls"
      end
    end
  end
end
