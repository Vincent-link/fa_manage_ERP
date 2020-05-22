class UserTitle < ApplicationRecord
  has_many :users, dependent: :destroy
end
