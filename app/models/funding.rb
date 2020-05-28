class Funding < ApplicationRecord
  include ModelState::FundingState

  belongs_to :company

  has_many :time_lines, -> {order(created_at: :desc)},class_name: 'TimeLine'
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
        self.create(fudning_company_contact.slice(:name, :position_id, :email,
                                                  :mobile, :wechat, :is_attend,
                                                  :is_open, :description))
      end
    end
  end
end
