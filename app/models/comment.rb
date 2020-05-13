class Comment < ApplicationRecord
  acts_as_paranoid
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  before_validation :set_current_user

  def set_current_user
    self.user_id ||= User.current.id
  end
end
