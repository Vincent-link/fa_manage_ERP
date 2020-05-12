class UserRole < ApplicationRecord
  acts_as_paranoid

  belongs_to :role
  belongs_to :user
end
