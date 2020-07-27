class Calendar < ApplicationRecord
  acts_as_paranoid

  include StateConfig
  include NotificationExtend

  has_many :calendar_members
  has_many :org_members, -> {where(memberable_type: 'Member')}, class_name: 'CalendarMember'
  has_many :com_members, -> {where(memberable_type: 'Contact')}, class_name: 'CalendarMember'
  has_many :user_members, -> {where(memberable_type: 'User')}, class_name: 'CalendarMember'
  has_many :calendar_users, through: :user_members, source: :memberable, source_type: 'User'
  belongs_to :user
  belongs_to :funding, optional: true
  belongs_to :company, optional: true
  belongs_to :organization, optional: true
  belongs_to :track_log, optional: true
  has_many :track_log_details, as: :linkable

  before_validation :set_current_user
  before_save :set_meeting_status
  before_validation :delete_when_cancel
  after_save :gen_track_log_detail
  after_save :gen_org_meeting_info

  delegate :name, to: :organization, allow_nil: true, prefix: true
  delegate :name, :location_city_id, :location_province_id, to: :company, allow_nil: true, prefix: true
  delegate :status, :round_id, to: :funding, allow_nil: true, prefix: true
  delegate :status, :members, to: :track_log, allow_nil: true, prefix: true

  attr_accessor :ir_review_syn, :newsfeed_syn, :investor_summary

  scope :nearly, -> {where(started_at: (Date.today.beginning_of_month - 3.month)..(Date.today.beginning_of_month + 2.month))}

  state_config :meeting_type, config: {
      face: {value: 1, desc: '线下约见'},
      tel: {value: 2, desc: '电话约见'},
  }

  state_config :meeting_category, config: {
      roadshow: {value: 1, desc: '路演会议'},
      com_meeting: {value: 2, desc: '约见公司'},
      org_meeting: {value: 3, desc: '约见投资人'},
  }

  state_config :status, config: {
      new: {value: 1, desc: '待约见'},
      meet: {value: 2, desc: '待填写纪要'},
      done: {value: 3, desc: '已完成'},
      cancel: {value: 4, desc: '已取消'}
  }

  def result_track_log_detail
    self.track_log_details.find {|ins| ins.detail_type_calendar_result?}
  end

  def contact_ids=(contact_ids)
    self.calendar_members.where(memberable_type: 'Contact').where.not(memberable_id: contact_ids).destroy_all
    contact_ids.each do |user_id|
      self.calendar_members.find_or_initialize_by(memberable_type: 'Contact', memberable_id: user_id)
    end
  end

  def member_ids=(member_ids)
    self.calendar_members.where(memberable_type: 'Member').where.not(memberable_id: member_ids).destroy_all
    member_ids.each do |user_id|
      self.calendar_members.find_or_initialize_by(memberable_type: 'Member', memberable_id: user_id)
    end
  end

  def cr_user_ids=(cr_user_ids)
    self.calendar_members.where(memberable_type: 'User').where.not(memberable_id: cr_user_ids).destroy_all
    cr_user_ids.each do |user_id|
      self.calendar_members.find_or_initialize_by(memberable_type: 'User', memberable_id: user_id)
    end
  end

  def address
    if self.address_id
      if self.address_id >= 100000
        Address.find(self.address_id)
      else
        Zombie::DmAddress.find(self.address_id)
      end
    end
  end

  def gen_track_log_detail
    if self.meeting_category_roadshow? && self.track_log
      if self.previous_changes.has_key? :track_result
        self.track_log.change_status_by_calendar(self.id, self.track_result, reason) if self.track_result
      else
        action = if self.previous_changes.has_key? :id
                   'create'
                 else
                   case self.status
                   when Calendar.status_cancel_value
                     'delete'
                   else
                     'update'
                   end
                 end
        self.track_log.gen_meeting_detail(User.current.id, self.id, action, reason)
      end
    end
  end

  def gen_org_meeting_info
    if self.meeting_category_org_meeting?
      if self.ir_review_syn
        self.organization.ir_reviews.create(content: self.summary)
        self.create_ir_review_notification(self.organization_id, self.summary)
      end
      if self.newsfeed_syn
        self.organization.newsfeeds.create(content: self.summary)
      end
      if self.investor_summary.present?
        investor_summary.each do |k, v|
          member = Member.find(k)
          member.update ir_review: v
        end
      end
    end
  end

  def set_current_user
    self.user_id ||= User.current&.id
  end

  def set_meeting_status
    self.status = Calendar.status_done_value if self.summary.present? && !self.status_cancel?
  end

  def delete_when_cancel
    self.destroy if self.status_cancel?
  end
end
