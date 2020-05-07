class InvestorGroup < ApplicationRecord
  has_many :investor_group_members
  has_many :members, through: :investor_group_members
  has_many :organizations, through: :members
  belongs_to :user
end
