class Funding < ApplicationRecord
  include ModelState::FundingState

  belongs_to :company

  has_many :time_lines, class_name: 'TimeLine'
  has_many :funding_company_contacts, class_name: 'FundingCompanyContact'

  has_many :funding_project_users, -> {kind_funding_project_users}, class_name: 'FundingUser'
  has_many :project_users, through: :funding_project_users, source: :user

  has_many :funding_bd_leader, -> {kind_bd_leader}, class_name: 'FundingUser'
  has_many :bd_leader, through: :funding_bd_leader, source: :user

  has_many :funding_execution_leader, -> {kind_execution_leader}, class_name: 'FundingUser'
  has_many :execution_leader, through: :funding_execution_leader, source: :user

end
