class Calendar < ApplicationRecord
  acts_as_paranoid

  include StateConfig

  has_many :calendar_members
  belongs_to :user
  belongs_to :address, optional: true
  belongs_to :funding, optional: true
  belongs_to :company, optional: true
  belongs_to :organization, optional: true

  state_config :meeting_type, config: {
      face: {value: 1, desc: '线下约见'},
      tel: {value: 2, desc: '电话约见'},
  }

  state_config :meeting_category, config: {
      roadshow: {value: 1, desc: '路演会议'},
      com_meeting: {value: 2, desc: '约见公司'},
      org_meeting: {value: 2, desc: '约见投资人'},
  }

  def company_contact_ids=(company_contact_ids)
    company_contact_ids.each do |user_id|
      self.calendar_members.build(memberable_type: 'CompanyContact', memberable_id: user_id)
    end
  end

  def member_ids=(member_ids)
    member_ids.each do |user_id|
      self.calendar_members.build(memberable_type: 'Member', memberable_id: user_id)
    end
  end

  def cr_user_ids=(cr_user_ids)
    cr_user_ids.each do |user_id|
      self.calendar_members.build(memberable_type: 'User', memberable_id: user_id)
    end
  end
end
