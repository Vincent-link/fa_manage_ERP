class InvestorGroupMember < ApplicationRecord
  belongs_to :investor_group
  belongs_to :member
end
