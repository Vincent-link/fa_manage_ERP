class Member < ApplicationRecord
  acts_as_paranoid
  has_paper_trail
  searchkick language: 'chinese'

  include StateConfig
  include BlobFileSupport

  has_one_attached :avatar
  has_one_attached :card
  has_blob_upload :avatar, :card


  acts_as_taggable_on :hot_tags

  belongs_to :organization, optional: true
  belongs_to :sponsor, class_name: 'User', optional: true

  has_many :member_user_relations
  has_many :users, through: :member_user_relations
  has_many :member_resumes
  has_many :track_log_members
  has_many :track_logs, through: :track_log_members

  has_many :email_receivers, as: :receiverable
  has_many :email_tos, as: :toable

  delegate :name, to: :organization, prefix: true

  state_config :report_type, config: {
      solid: {value: 1, desc: '实线汇报'},
      virtual: {value: 0, desc: '虚线汇报'},
  }

  state_config :scale, config: {
      lt_1000: {value: 1, desc: '1000万以下'},
      gt_1000_lt_3000: {value: 2, desc: '1000万-3000万'},
      gt_3000_lt_5000: {value: 3, desc: '3000万-5000万'},
      gt_5000_lt_10000: {value: 4, desc: '5000万-1亿'},
      gt_10000_lt_20000: {value: 5, desc: '1亿-2亿'},
      gt_20000: {value: 6, desc: '2亿以上'},
  }

  after_validation :save_to_dm
  after_commit :save_report_relation
<<<<<<< HEAD
  after_commit :create_notification
=======
  after_commit :create_dimission_notification
>>>>>>> 0a693f1... notification investor

  attr_accessor :solid_lower_ids, :virtual_lower_ids, :report_line

  # searchkick scope and config
  scope :search_import, -> {includes(:organization, :users)}

  def search_data
    attributes.merge organization_name: self.organization_name,
                     user_ids: self.user_ids
  end

  def save_to_dm
    if self.new_record?
      dm_org = Zombie::DmInvestor._by_id(self.organization_id)
      member = dm_org.person_create self.attributes_for_dm
      self.id = member.id
    end
  end

  [:address, :report_relations].each do |attribute_name|
    define_method(attribute_name) do
      dm_member.send(attribute_name)
    end
  end

  def organization_teams
    OrganizationTeam.where(id: self.team_ids)
  end

  def dm_member
    @dm_member ||= Zombie::DmMember.find(self.id)
  end

  def attributes_for_dm
    dm_key_map = {
        'name' => 'name',
        'en_name' => 'en_name',
        'tel' => 'contact_tel',
        'email' => 'contact_email',
        'position_rank_id' => 'position_rank_id',
        'position' => 'position',
        'intro' => 'intro',
        'wechat' => 'weixin_url'
    }
    self.attributes.transform_keys {|k| dm_key_map[k]}.compact
  end

  def tag_desc
    self.tags.map(&:name)
  end

  def covered_by= ids
    self.member_user_relations.where.not(user_id: ids).destroy_all
    ids.each do |u_id|
      self.member_user_relations.find_or_initialize_by(user_id: u_id)
    end
  end

  def dm_lower_report_relation
    @lower_report_relation ||= Zombie::DmMemberReportRelation.where(superior_id: self.id).inspect
  end

  def save_report_relation
    if self.solid_lower_ids || self.virtual_lower_ids
      self.solid_lower_ids ||= []
      self.virtual_lower_ids ||= []
      relation_arr = []
      relation_arr |= dm_lower_report_relation.select {|relation| relation.report_type == 1 && self.solid_lower_ids.delete(relation.superior_id)}
      relation_arr |= dm_lower_report_relation.select {|relation| relation.report_type == 0 && self.virtual_lower_ids.delete(relation.superior_id)}
      solid_lower_ids.each {|ins| relation_arr << {member_id: ins, report_type: 1}}
      virtual_lower_ids.each {|ins| relation_arr << {member_id: ins, report_type: 0}}
      dm_member.update_report_relations(relation_arr, 'lower')
    end

    if self.report_line
      dm_member.update_report_relations(self.report_line, 'superior')
    end

    @lower_report_relation = nil
  end

  def solid_report_lower
    Member.where(id: dm_lower_report_relation.select {|relation| relation.report_type == 1}.map(&:member_id))
  end

  def virtual_report_lower
    Member.where(id: dm_lower_report_relation.select {|relation| relation.report_type == 0}.map(&:member_id))
  end

  def solid_report_superior
    Member.where(id: report_relations.select {|relation| relation.report_type == 1}.map(&:superior_id))
  end

  def virtual_report_superior
    Member.where(id: report_relations.select {|relation| relation.report_type == 0}.map(&:superior_id))
  end

  def self.es_search(params, options = {})
    where_hash = {}
    params[:query] = '*' if params[:query].blank?
    where_hash[:sector_ids] = {all: params[:sector_ids]} if params[:sector_ids].present?
    where_hash[:round_ids] = {all: params[:round]} if params[:round].present?
    where_hash[:currency_ids] = {all: params[:currency]} if params[:currency].present?
    where_hash[:level] = params[:level] if params[:level].present?
    where_hash[:organization_id] = params[:organization_id] if params[:organization_id].present?
    where_hash[:scale_ids] = params[:scale] if params[:scale].present?
    where_hash[:position_rank_id] = params[:position_rank_id] if params[:position_rank_id]
    where_hash[:tel] = params[:tel] if params[:tel]
    where_hash[:user_ids] = params[:covered_by] if params[:covered_by]
    if params[:amount_min].present? || params[:amount_max].present?
      range = (params[:amount_min] || 0)..(params[:amount_max] || 9999999)
      where_hash[:_or] = [{usd_amount_min: range}, {usd_amount_max: range}]
    end
    if params[:investor_group_id]
      if where_hash[:id]
        where_hash[:id] &= InvestorGroup.find(params[:investor_group_id]).member_ids
      else
        where_hash[:id] = InvestorGroup.find(params[:investor_group_id]).member_ids
      end
    end
    if params[:followed]
      if where_hash[:id]
        where_hash[:id] &= User.current.follows.member.pluck(:id)
      else
        where_hash[:id] = User.current.follows.member.pluck(:id)
      end
    end

    Member.search(params[:query], options.merge(where: where_hash, page: params[:page] || 1, per_page: params[:per_page] || 30, highlight: DEFAULT_HL_TAG))
  end

  def self.syn_by_dm_member(dm_member)
    member = Member.find_by_id(dm_member.id) || Member.new(id: dm_member.id)
    member.organization_id = dm_member.investor_id
    member.name = dm_member.name_without_prefix
    member.en_name = dm_member.en_name
    member.email = dm_member.contact_email
    member.tel = dm_member.contact_tel
    member.wechat = dm_member.weixin_url
    member.avatar = dm_member.logo
    member.position = dm_member.position
    member.position_rank_id = dm_member.position_rank_id
    member.address_id = dm_member.address_id
    member.sector_ids = dm_member.sectors.map(&:id)
    member.currency_ids = dm_member.currencies.map(&:id)
    member.invest_stage_ids = dm_member.invest_stages.map(&:id)
    member.is_dimission = dm_member.is_dimission
    if member.changed?
      member.syn_at = Time.now
      member.save!
    end
  end

  def self.syn(id)
    Member.transaction do
      if dm_member = Zombie::DmMember.where(id: id).includes(:person)._select(:id, :investor_id, :name, :en_name, :contact_email, :contact_tel, :weixin_url, :logo, :position_rank_id, :position, :address_id, :sectors, :currencies, :invest_stages, :is_dimission).first
        Member.syn_by_dm_member dm_member
      end
    end
  end

  def create_notification
    if self.previous_changes[:is_dimission].present? && self.previous_changes[:is_dimission][1]
      if self.previous_changes[:organization_id].present?
        before = Organization.find(self.previous_changes[:organization_id][0])
        content = Notification.investor_type_config[:resign][:desc].call(self.name, before.name)
      else
        content = Notification.investor_type_config[:resign][:desc].call(self.name, self.organization.name) if self.organization.present?
      end
      self.member_user_relations.map {|e| Notification.create(notification_type: Notification.notification_type_value("investor"), content: content, user_id: e.user_id, is_read: false, notice: {member_id: self.id}) if content.present?}
    end

    if self.previous_changes[:organization_id].present?
      before = Organization.find(self.previous_changes[:organization_id][0])
      after = Organization.find(self.previous_changes[:organization_id][1])

      content = Notification.investor_type_config[:institutional_change][:desc].call(self.name, before.name, after.name)
      self.member_user_relations.map {|e| Notification.create(notification_type:  Notification.notification_type_value("investor"), content: content, user_id: e.user_id, is_read: false, notice: {member_id: self.id})}
    end

    if self.previous_changes[:position_rank_id].present?
      before = Organization.find(self.previous_changes[:organization_id][0])
      after = Organization.find(self.previous_changes[:organization_id][1])

      content = Notification.investor_type_config[:position_change][:desc].call(self.name, self.previous_changes[:position_rank_id][0], self.previous_changes[:position_rank_id][1])
      self.member_user_relations.map {|e| Notification.create(notification_type:  Notification.notification_type_value("investor"), content: content, user_id: e.user_id, is_read: false, notice: {member_id: self.id})}
    end
  end
end
