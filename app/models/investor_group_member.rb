class InvestorGroupMember < ApplicationRecord
  belongs_to :investor_group, touch: true
  belongs_to :investor_group_organization, optional: true
  belongs_to :member
end
