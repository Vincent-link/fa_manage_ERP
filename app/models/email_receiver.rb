class EmailReceiver < ApplicationRecord
  belongs_to :email
  belongs_to :receiverable, polymorphic: true, optional: true

  before_create :no_push

  include StateConfig

  state_config :kind, config: {
      cc:    { value: 1, desc: "抄送人"  },
      bcc:   { value: 2, desc: "密送人"  }
  }

  def no_push
    self.status = Email.status_no_push_value
  end
end
