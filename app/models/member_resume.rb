class MemberResume < ApplicationRecord
  include CurrentUserSupport

  belongs_to :member
  belongs_to :organization
  belongs_to :user, optional: true

  delegate :name, to: :organization, prefix: true
  delegate :name, to: :member, prefix: true
end
