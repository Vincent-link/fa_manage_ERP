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
    resource 'verify_title_update', '审核title修改' do
      can :verify, Verification, verification_type: :title_update
    end
    resource 'one_vote_veto', '一票否决' do
      can :one_vote, 'veto'
    end
    resource 'remind_to_vote', '提醒投票' do
      can :remind, 'to_vote'
    end
  end

  group 'workbench', '工作台' do
    resource 'operate', '人员运营' do
      can :operate, User
    end
  end

  group :knowledge, '知识库' do
    resource 'read_organization', '查看投资机构' do
      can :read, Organization
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
    resource 'export_investevent', '导出投资案例' do
      can :export, 'investevent'
    end
    resource 'read_progress_funding', '查看项目进展' do
      can :read_progress, Funding
    end
    resource 'edit_progress_funding', '更新项目进展' do
      can :edit_progress, Funding
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

  group :role, '权限管理' do
    resource 'manage_role', '管理权限' do
      can :manage, Role
      can :manage, User
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

    # resource 'push_ka_email', 'KA推送' do
    #   can :read, EmailTemplate, name: 'KA推送'
    # end
  end

  group :external, '外部数据权限' do
    resource 'read_force_call_report', '查看force call report' do
      can :read, 'force_call_report'
    end

    resource 'download_force_call_report', '下载force call report' do
      can :download, 'force_call_report'
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
