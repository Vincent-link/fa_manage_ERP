class InvestorGroup < ApplicationRecord
  has_many :investor_group_members
  has_many :members, through: :investor_group_members
  has_many :investor_group_organizations
  has_many :organizations, through: :investor_group_organizations
  belongs_to :user

  before_validation :set_current_user

  def set_current_user
    self.user_id ||= User.current.id
  end

  def member_count
    self.investor_group_members.size
  end
end
