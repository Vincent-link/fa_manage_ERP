class Follow < ApplicationRecord
  belongs_to :followable, polymorphic: true
  belongs_to :user

  scope :member, -> {where(followable_type: 'Member')}
end
