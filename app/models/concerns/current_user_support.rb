module CurrentUserSupport
  extend ActiveSupport::Concern

  included do
    before_validation :set_current_user

    def set_current_user
      self.user_id ||= User.current.id
    end
  end
end


