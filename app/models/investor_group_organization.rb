class InvestorGroupOrganization < ApplicationRecord
  belongs_to :investor_group
  belongs_to :organization
  has_many :investor_group_members, dependent: :delete_all
  has_many :members, through: :investor_group_members
  has_many :covered_users, through: :members, source: :users

  delegate :name, to: :organization
end
