class EmailToGroup < ApplicationRecord
  belongs_to :email
  belongs_to :organization
  has_many :email_tos
  has_many :users, through: :email_tos, source: :toable, source_type: 'User'
  has_many :members, through: :email_tos, source: :toable, source_type: 'Member'

  before_create :gen_status

  include StateConfig

  state_config :status, config: {
      not_push:     { value: 1, desc: "未推送"  },
      success:      { value: 2, desc: "推送成功"},
      fail:         { value: 3, desc: "推送失败"},
      pushing:      { value: 4, desc: "推送中"},
  }

  def gen_status
    self.status = EmailToGroup.status_not_push_value
  end

  def dear_to
    tos = self.email_tos.includes(:toable).map{|ins| ins.person_title || ins.toable&.name}.compact
    # if tos.present?
    #   "<button>#{tos.join('</button><button>')}</button>"
    # else
    #   ""
    # end
    tos.join('、')
  end

  def real_to
    self.email_tos.includes(:toable).map{|ins| ins.toable&.name}.compact.join('、')
  end
end
