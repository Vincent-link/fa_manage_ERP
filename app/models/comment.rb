class Comment < ApplicationRecord
  acts_as_paranoid

  include NotificationExtend
  
  belongs_to :commentable, -> { with_deleted }, polymorphic: true
  belongs_to :user

  before_validation :set_current_user
  after_commit :create_notification

  def set_current_user
    self.user_id ||= User.current.id
  end

  def create_notification
    if self.type == "IrReview"
      self.create_ir_review_notification(self.commentable_id, self.content)
    end
  end
end
