# 关键字
# manage ======> 所有权限
# read   ======> index和show的权限
class Resource
  include Resourcing

  group 'admin', '管理员' do
    resource 'manage_all', '超级权限' do
      can :manage, :all
    end
    resource 'update_system_config', '管理系统配置' do
      can :update, 'system_config'
    end
    resource 'update_ka_config', '管理KA配置' do
      can :update_ka, Company
      can :update_ka, 'system_config'
    end
    resource 'read_verification', '查看审核' do
      can :read, Verification
    end
    resource 'one_vote_veto', '一票否决权' do
      can :read, Verification
    end
  end

  group 'workbench', '工作台' do
    resource 'gather_weeklyreport', '周报汇总' do
      can :gather_weeklyreport, Document
    end
    resource 'new_research_report', '新增研究报告' do
      can :new, ResearchReport
    end
    resource 'gather_research_report', '研究报告汇总' do
      can :read, ResearchReport
      can :gather, ResearchReport
      can :read, ResearchReportFolder
    end
    resource 'download_research_report', '研究报告下载' do
      can :download, ResearchReport
    end
    resource 'mamage_research_report', '研究报告删除和编辑' do
      can :edit, ResearchReport
    end
    resource 'folder_research_report', '研究报告目录管理' do
      can :folder, ResearchReport
    end


    resource 'manage_research_report_folder', '新研究报告目录管理' do
      can :manage, ResearchReportFolder
    end
    resource 'read_research_report_folder', '新研究报告目录查看' do
      can :read, ResearchReportFolder
    end
    resource 'manage_monthly_report_folder', '月会材料目录管理' do
      can :manage, MonthlyReportFolder
    end
    resource 'read_monthly_report_folder', '查看、上传月会材料' do
      can :read, MonthlyReportFolder
    end
    resource 'manage_research_report', '研究报告管理' do
      can :manage, ResearchReport
    end
    resource 'read_all_monthly_report', '查看所有月会材料' do
      can :read_all, MonthlyReport
    end

    resource 'new_time_report', '新增TimeReport' do
      can :new, TimeReport
    end
    resource 'read_time_report', '查看TimeReport' do
      can :read, TimeReport
    end
    resource 'upload_weeklyreport', '上传周报' do
      can :upload_weeklyreport, Document
    end
    resource 'download_weeklyreport', '下载周报' do
      can :download_weeklyreport, Document
    end
    resource 'operate', '人员运营' do
      can :operate, User
    end
    resource 'new_capacity', '新增Capacity' do
      can :new, Capacity
    end
    resource 'manage_capacity', '管理Capacity' do
      can :manage, Capacity
    end
    resource 'export_all', '导出权限' do
      can :export, :all
    end

    resource 'read_biweekly', '查看双周报汇总' do
      can :read, Biweekly
    end

    resource 'read_secret_biweekly', '查看双周报保密进展' do
      can :read_secret, Biweekly
    end

    resource 'commit_biweekly', '提交双周报进展' do
      can :commit, Biweekly
    end

    resource 'abort_biweekly', '撤回双周报进展' do
      can :abort, Biweekly
    end

    # resource 'read_meeting_note', '查看meeting_note权限' do
    #   can :read, 'hc_meeting_note'
    #   can :read, InvestorNoteRecord
    #   can :read, InvestorNote
    # end
    resource 'export_meeting_note', '下载meeting_note权限' do
      can :export, 'hc_meeting_note'
      can :export, InvestorNoteRecord
      can :export, InvestorNote
    end
  end

  group :knowledge, '知识库' do
    resource 'read_info_operate_push', '查看机构操作记录' do
      can :read, InfoOperatePush
    end
    resource 'push_info_operate_push', '推送机构操作记录' do
      can :push, InfoOperatePush
    end

    resource 'read_organization', '查看投资机构' do
      can :read, Organization
    end
    resource 'manage_organization/ir_review', '管理机构IrReview' do
      can :manage, Organization::IrReview
    end
    resource 'manage_organization/newsfeed', '管理机构NewsFeed' do
      can :manage, Organization::Newsfeed
    end
    resource 'manage_organization/decision_flow', '管理机构决策流程' do
      can :manage, Organization::DecisionFlow
    end
    resource 'manage_organization/remark', '管理机构备注' do
      can :manage, 'organization/remark'
    end
    resource 'new_organization', '新增投资机构' do
      can :new, Organization
    end
    resource 'pick_organization', 'pick投资机构' do
      can :pick, Organization
    end
    resource 'edit_organization', '编辑投资机构' do
      can :edit, Organization
    end
    resource 'merge_organization', '合并投资机构' do
      can :merge, Organization
    end
    resource 'destroy_investor', '删除投资人' do
      can :destroy, Member
    end
    resource 'read_investor', '查看投资人' do
      can :read, Member
    end
    resource 'update_investor', '更新投资人' do
      can :update, Member
    end
    resource 'manage_investor', '管理投资人' do
      can :manage, Member
    end
    resource 'resign_investor', '标记投资人离职' do
      can :resign, Member
    end
    resource 'manage_member_user_relation', '维护投资人亲密度' do
      can :manage, MemberUserRelation
    end
    resource 'manage_investor/remark', '管理投资人备注' do
      can :manage, 'investor/remark'
    end
    resource 'merge_investor', '合并机构成员' do
      can :merge, Member
    end
    resource 'pick_member', 'pick投资人' do
      can :pick, Member
    end
    resource 'read_on_going_tic_organization', '查看进行中的项目交互' do
      can :read_interest, TicOrganization, funding: {:status => [2, 3]}
      can :read_interest, TicInvestor, funding: {:status => [2, 3]}
    end
    resource 'read_company', '查看创业公司' do
      can :read, Company
    end
    resource 'merge_company', '合并公司' do
      can :merge, Company
    end
    resource 'read_circuit_company', '查看赛道' do
      can :read_circuit, Company
    end
    resource 'edit_circuit_company', '编辑赛道' do
      can :edit_circuit, Company
    end
    resource 'export_circuit_company', '导出赛道列表' do
      can :export_circuit, Company
    end
    resource 'read_all_ka_company', '跨组查看KA列表及查看覆盖进展' do
      can :read_ka, Company
      can :read_all_ka, Company
    end
    resource 'read_ka_company', '跨组查看KA列表' do
      can :read_ka, Company
    end
    resource 'read_all_contact', '查看所有联系人' do
      can :read_team, Company::Contact
    end
    resource 'delete_all_contact', '删除所有联系人' do
      can :delete_team, Company::Contact
    end
    resource 'read_strategy/organization', '查看战投机构' do
      can :read, Strategy::Organization
    end
    resource 'cr_strategy/organization', '查看战投机构CR推荐' do
      can :cr, Strategy::Organization
    end
    resource 'contact_strategy/organization', '查看战投机构公司联系人' do
      can :contact, Strategy::Organization
    end
    resource 'interview_strategy/organization', '查看战投机构访谈信息' do
      can :interview, Strategy::Organization
    end
    resource 'new_strategy/organization', '新增战投机构' do
      can :new, Strategy::Organization
    end
    resource 'read_funding_company', '在创业公司页查看项目' do
      can :read_funding, Company
    end
    resource 'read_callreport_company', '在创业公司页查看CallReport' do
      can :read_callreport, Company
      can :manage, CallReportRecord
    end
    resource 'read_all_callreport', '查看所有CallReport' do
      can :read, CallReport
    end
    resource 'read_all_none_secret_callreport', '查看所有非保密CallReport' do
      can :read, CallReport, :is_secret => false
    end
    resource 'secret_callreport', '查看保密CallReport' do
      can :secret, CallReport, :is_secret => true
    end
    resource 'read', '查看所有拜访memo' do
      can :read, ReqFeedback
    end
    resource 'delete_hand_typing_recommend', '删除手动录入推荐' do
      can :delete_recommend, Organization
    end

    resource 'kol_member_manage', '管理kol投资人' do
      can :manage, 'KolMember'
      can :manage, KolNote
    end

    resource 'kol_member_export', '导出kol投资人' do
      can :export, 'KolMember'
    end

    # resource 'add_meeting_note', "添加MeetingNote" do
    #   can :add, MeetingNote
    # end

    resource 'export_investevent', '导出投资案例' do
      can :export, 'investevent'
    end

    resource 'read_custom_investor_list', '查看FSG侧边栏' do
      can :read, CustomInvestorList
    end

    resource 'read_investor_group_config', '查看投资组配置' do
      can :read, 'InvestorGroupConfig'
    end

    resource 'export_custom_investor_list', '导出投资组加样式投资人列表' do
      can :export, CustomInvestorList
    end

    resource 'export_investor_group_config', '导出投资组配置投资人列表' do
      can :export, 'InvestorGroupConfig'
    end

    resource 'update_custom_investor_list', '编辑FSG侧边栏' do
      can :update, CustomInvestorList
    end

    resource 'update_investor_group_config', '编辑投资组配置' do
      can :update, 'InvestorGroupConfig'
    end

    resource 'update_default_custom_investor_list', '编辑FSG侧边栏默认配置' do
      can :update_default, CustomInvestorList
    end


  end

  group :dashboard, '仪表盘' do
    resource 'stat_funding', '统计项目信息' do
      can :stat, Funding
    end
    resource 'read_capacity', '查看Capacity' do
      can :read, Capacity
    end
    resource 'add_capacity', '补录Capacity' do
      can :add, Capacity
    end
    resource 'enter_interaction_statistics', '交互统计-全部' do
      can :enter_interaction_statistics, Funding
    end
    resource 'summary_interaction_statistics', '交互统计-项目维度' do
      can :summary_interaction_statistics, Funding
    end
    resource 'details_interaction_statistics', '交互统计-项目交互情况' do
      can :details_interaction_statistics, Funding
    end
    resource 'organizations_interaction_statistics', '交互统计-机构交互情况' do
      can :organizations_interaction_statistics, Organization
    end
  end

  group :funding, '项目相关' do
    resource 'read_funding', '查看项目详情' do
      can :read, Funding
    end
    resource 'edit_funding', '编辑项目信息' do
      can :edit, Funding
    end
    resource 'secret_funding', '查看保密项目' do
      can :secret, Funding
    end
    resource 'bsc_funding', '查看项目BSC信息' do
      can :bsc, Funding
    end
    resource 'read_all_funding', '查看所有项目列表' do
      can :read_all, Funding
      can :read_mine, Funding
    end
    resource 'read_mine_funding', '查看我的项目列表' do
      can :read_mine, Funding, users: {:id => @user.id}
    end
    resource 'process_funding', '推进项目' do
      can :process, Funding
    end
    resource 'operate_funding', '项目运营（启动项目）' do
      can :operate, Funding
    end
    resource 'assign_funding', '指派项目' do
      can :assign, Funding
    end
    resource 'read_progress_funding', '查看项目进展' do
      can :read_progress, Funding
    end
    resource 'edit_progress_funding', '更新项目进展' do
      can :edit_progress, Funding
    end
    resource 'read_document_funding', '查看项目文档' do
      can :read_document, Funding
    end
    resource 'edit_document_funding', '更新项目文档' do
      can :edit_document, Funding
    end
    resource 'read_el_funding', '查看项目EL' do
      can :read_el, Funding
    end
    resource 'read_weekly_update_funding', '查看项目WeeklyUpdate' do
      can :read_weekly_update, Funding
    end
    resource 'read_ts_funding', '查看项目TS' do
      can :read_ts, Funding
    end
    resource 'read_closing_memo_funding', '查看项目ClosingMemo' do
      can :read_closing_memo, Funding
    end
    resource 'edit_callreport_funding', '查看项目CallReport' do
      can :edit_callreport, Funding
      can :manage, CallReportRecord
    end
    resource 'questionnaire_funding', '发送问卷反馈' do
      can :questionnaire, Funding
    end
    resource 'read_own_evaluation_funding', '查看我的项目互评' do
      can :read_own_evaluation, Funding
    end
    resource 'read_all_evaluation_funding', '查看全部项目互评' do
      can :read_all_evaluation, Funding
    end
    resource 'edit_evaluation_funding', '启动项目互评' do
      can :edit_evaluation, Funding
    end
    resource 'review_funding', '复盘项目' do
      can :review, Funding
    end
  end

  group :tic, 'TIC相关' do
    resource 'manage_tic', 'TIC所有权限' do
      can :show_tic, Funding
      can :prepare_tic, Funding
      can :operate_tic, Funding
    end
    resource 'show_tic', '查看TIC' do
      can :show_tic, Funding
    end
    resource 'prepare_tic', '初筛机构' do
      can :prepare_tic, Funding
    end
    resource 'operate_tic', '确认机构' do
      can :operate_tic, Funding
    end
  end

  group :track_log, 'TrackLog相关' do
    resource 'manage_track_log_funding', 'TrackLog所有权限' do
      can :manage_track_log, Funding
    end
  end

  group :role, '权限管理' do
    resource 'manage_role', '管理权限' do
      can :manage, Role
      can :manage, User
    end
  end

  group :document, '文档权限' do
    resource 'read_model', '查看财务模型' do
      can :read, Document, doc_type: [15]
    end
    resource 'read_valuation', '查看估值模型' do
      can :read, Document, doc_type: [14]
    end
    resource 'read_ts', '查看Term Sheet' do
      can :read, Document, doc_type: [19, 20, 30]
    end
    resource 'read_legal', '查看法律文件' do
      can :read, Document, doc_type: [23, 24]
    end
    resource 'read_closing_memo', '查看Closing Memo' do
      can :read, Document, doc_type: [26]
    end
    resource 'read_pitch_book', '查看Pitch Book' do
      can :read, Document, doc_type: [5]
    end
  end

  group :system_config, '管理配置权限' do
    resource 'recent_active_organization', '查看近期活跃机构' do
      can :read, RecentActiveOrganization
    end
  end

  group :common_task, '日常任务' do
    resource 'manage_common_task', '编辑日常任务' do
      can :manage, CommonTask
    end
  end

  group :tools, '便捷工具' do
    # resource 'push_email', '邮件推送' do
    #   can :read, Email
    # end
    #
    # resource 'read_email_group', '邮件组配置' do
    #   can :read, EmailGroup
    # end

    resource 'edit_email_group', '管理邮件组' do
      can :manage, EmailGroup
      # can :read, EmailGroupDetail
    end

    resource 'manage_email', '管理邮件' do
      can :manage, Email
    end
    # resource 'push_ka_email', 'KA推送' do
    #   can :read, EmailTemplate, name: 'KA推送'
    # end
  end

  group :external, '外部数据权限' do
    resource 'read_force_call_report', '查看force call report' do
      can :read, 'force_call_report'
      can :read, ForceFileStub
    end

    resource 'download_force_call_report', '下载force call report' do
      can :download, 'force_call_report'
      can :download, ForceFileStub
    end
  end



  def self.authorize_questionnaire(sso_id, action, target) #获取权限
    if target.is_a? Array
      target = target[0].constantize.find_by_id target[1]
    else
      target = target.constantize
    end

    Ability.new(User.find_by_sso_id sso_id).can? action.to_sym, target
  end

end
