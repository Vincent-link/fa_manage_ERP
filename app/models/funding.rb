class Funding < ApplicationRecord
  acts_as_paranoid

  include ModelState::FundingState

  belongs_to :company

  has_many :time_lines, -> { order(created_at: :desc) }, class_name: 'TimeLine'
  has_many :funding_company_contacts, class_name: 'FundingCompanyContact'

  has_many :funding_project_users, -> { kind_funding_project_users }, class_name: 'FundingUser'
  has_many :project_users, through: :funding_project_users, source: :user

  has_many :funding_bd_leader, -> { kind_bd_leader }, class_name: 'FundingUser'
  has_many :bd_leader, through: :funding_bd_leader, source: :user

  has_many :funding_execution_leader, -> { kind_execution_leader }, class_name: 'FundingUser'
  has_many :execution_leader, through: :funding_execution_leader, source: :user

  def add_project_follower(params)
    if params[:project_user_ids].present?
      self.project_users_ids = params[:project_users_ids]
    end

    if params[:bd_leader_id].present?
      self.bd_leader_ids = [params[:bd_leader_id]]
    end

    if params[:execution_leader_id].present?
      self.execution_leader_ids = [params[:execution_leader_id]]
    end
  end

  def gen_funding_company_contacts(params)
    if params[:fudning_company_contacts].present?
      params[:fudning_company_contacts].each do |fudning_company_contact|
        self.gen_funding_company_contact(fudning_company_contact.slice(:name, :position_id, :email,
                                                                       :mobile, :wechat, :is_attend,
                                                                       :is_open, :description))
      end
    end
  end

  def gen_funding_company_contact(params)
    self.create(params.slice(:name, :position_id, :email,
                             :mobile, :wechat, :is_attend,
                             :is_open, :description))
  end

  def auth_status(status, go_to)
    if !([Funding.status_hold_value, Funding.status_pass_value].include? go_to) && !([Funding.status_hold_value, Funding.status_pass_value].include? status) && self.status != status
      raise "项目不是#{Funding.status_desc_for_value(status)}阶段不能移动到#{Funding.status_desc_for_value(go_to)}阶段"
    end

    raise '操作重复' if status == go_to

    case go_to
    when Funding.status_pass_value
      no_pass = [Funding.status_execution_value, Funding.status_closing_value, Funding.status_closed_value, Funding.status_paid_value]
      if no_pass.include? self.status
        raise "#{Funding.status_desc_for_value(self.status)}阶段不能移动到#{Funding.status_desc_for_value(Funding.status_pass_value)}阶段"
      end
    when Funding.status_hold_value
      no_hold = [Funding.status_reviewing_value, Funding.status_interesting_value, Funding.status_voting_value, Funding.status_closed_value, Funding.status_paid_value]
      if no_hold.include? self.status
        raise "#{Funding.status_desc_for_value(self.status)}阶段不能移动到#{Funding.status_desc_for_value(Funding.status_hold_value)}阶段"
      end
    end

    # todo 认领还需要审批那块（柳辉）
  end
end
