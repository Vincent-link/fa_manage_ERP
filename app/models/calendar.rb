class Calendar < ApplicationRecord
  acts_as_paranoid

  include StateConfig

  has_many :calendar_members
  has_many :org_members, -> {where(memberable_type: 'Member')}, class_name: 'CalendarMember'
  has_many :com_members, -> {where(memberable_type: 'Contact')}, class_name: 'CalendarMember'
  has_many :user_members, -> {where(memberable_type: 'User')}, class_name: 'CalendarMember'
  belongs_to :user
  belongs_to :address, optional: true
  belongs_to :funding, optional: true
  belongs_to :company, optional: true
  belongs_to :organization, optional: true
  belongs_to :track_log, optional: true
  has_many :track_log_deatils, as: :linkable

  before_validation :set_current_user
  after_create :gen_create_track_log_detail
  after_update :gen_update_track_log_detail

  state_config :meeting_type, config: {
      face: {value: 1, desc: '线下约见'},
      tel: {value: 2, desc: '电话约见'},
  }

  state_config :meeting_category, config: {
      roadshow: {value: 1, desc: '路演会议'},
      com_meeting: {value: 2, desc: '约见公司'},
      org_meeting: {value: 2, desc: '约见投资人'},
  }

  state_config :status, config: {
      new: {value: 1, desc: '未约见'},
      meet: {value: 2, desc: '已约见'},
      done: {value: 3, desc: '已完成'},
      cancel: {value: 4, desc: '已取消'}
  }

  def contact_ids=(contact_ids)
    contact_ids.each do |user_id|
      self.calendar_members.build(memberable_type: 'Contact', memberable_id: user_id)
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

  def gen_create_track_log_detail
    if self.track_log.present?
      self.track_log.gen_meeting_detail(User.current.id, self.id, 'create')
    end
  end

  def gen_update_track_log_detail
    user_id = User.current.id
    if self.track_log.present?
      case self.status
      when Calendar.status_cancel_value
        self.track_log.gen_meeting_detail(user_id, self.id, 'delete')
      else
        self.track_log.gen_meeting_detail(user_id, self.id, 'update')
      end
    end
  end

  def set_current_user
    self.user_id ||= User.current&.id
  end
end
