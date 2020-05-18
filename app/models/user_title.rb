class UserTitle < ApplicationRecord
  has_many :users, dependent: :destroy

  def users
  	User.where(user_title_id: self.id).pluck(:name)
  end
end
