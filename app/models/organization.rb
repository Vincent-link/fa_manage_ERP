class Organization < ApplicationRecord
  acts_as_paranoid
  has_paper_trail
  searchkick

  include StateConfig

  acts_as_taggable_on :organization_tags

  has_one_attached :logo

  has_many :members
  has_many :comments, as: :commentable
  has_many :ir_reviews, as: :commentable
  has_many :newsfeeds, as: :commentable
  # has_many :organization_tags
  has_many :lead_organization_relations, -> {relation_type_lead}, class_name: 'OrganizationRelation'
  has_many :mate_organization_relations, -> {relation_type_mate}, class_name: 'OrganizationRelation'
  has_many :lead_organizations, through: :lead_organization_relations, source: :relation_organization, class_name: 'Organization'
  has_many :mate_organizations, through: :mate_organization_relations, source: :relation_organization, class_name: 'Organization'
  has_many :organization_relations
  has_many :organization_teams
  has_many :calendars
  has_many :track_logs

  after_validation :save_to_dm

  delegate :addresses, to: :dm_organization, prefix: false

  scope :search_import, -> {includes(:ir_reviews, :newsfeeds, :comments, :members, :organization_tags)}

  state_config :level, config: {
      a: {value: 'a', desc: 'A'},
      b: {value: 'b', desc: 'B'},
      c: {value: 'c', desc: 'C'},
      d: {value: 'd', desc: 'D'}
  }

  state_config :tier, config: {
      t1: {value: 1, desc: 'T1'},
      t2: {value: 2, desc: 'T2'},
  }

  state_config :invest_period, config: {
      day_30: {value: 1, desc: '一个月以内'},
      mouth_2: {value: 2, desc: '两个月'},
      mouth_gt_3: {value: 3, desc: '三个月及以上'},
      other: {value: 10, desc: '不一定'},
  }

  state_config :org_nature, config: {
      a: {value: 1, desc: 'PE'},
      b: {value: 2, desc: 'VC'},
  }

  def logo_url
    self.logo.service_url
  end

  def logo_file= file_hash
    if file_hash
      if file_hash[:blob_id].present?
        self.logo.destroy! if self.logo.present?
        self.build_logo_attachment blob_id: file_hash[:blob_id]
      elsif file_hash[:id].blank?
        self.logo.destroy! if self.logo.present?
      end
    end
  end

  def can_delete?
    if track_logs.present? || calendars.present? || members.present? || comments.present? || organization_relations.present?
      false
    else
      true
    end
  end

  def search_data
    attributes.merge last_investevent_date: self.last_investevent&.birth_date,
                     ir_reviews: "#{self.ir_reviews.map(&:content).join(' ')}",
                     newsfeeds: "#{self.newsfeeds.map(&:content).join(' ')}",
                     comments: "#{self.comments.map(&:content).join(' ')}",
                     # organization_tags: "#{self.organization_tags.map(&:name).join(' ')}", todo tags
                     members: "#{self.members.map(&:name).join(' ')}"
  end

  def self.es_search(params)
    where_hash = {}
    where_hash[:sector_ids] = {all: params[:sector]} if params[:sector].present?
    where_hash[:round_ids] = {all: params[:round]} if !params[:any_round] && params[:round].present?
    where_hash[:currency_ids] = {all: params[:currency]} if params[:currency].present?
    where_hash[:level] = params[:level] if params[:level].present?
    if params[:amount_min].present? || params[:amount_max].present?
      range = (params[:amount_min] || 0)..(params[:amount_max] || 9999999)
      where_hash[:_or] = [{usd_amount_min: range}, {usd_amount_max: range}]
    end
    if params[:investor_group_id]
      where_hash[:id] = InvestorGroup.find(params[:investor_group_id]).organization_ids
    end

    order_hash = {}
    if params[:order_by]
      order_hash = {params[:order_by] => params[:order_type]}
    end

    Organization.search(params[:query], where: where_hash, order: order_hash, page: params[:page], per_page: params[:per_page], highlight: DEFAULT_HL_TAG)
  end

  def save_to_dm
    if self.new_record?
      dm_org = Zombie::DmInvestor.create_from_attribute self.attributes_for_dm
      self.id = dm_org.id
    end
  end

  def attributes_for_dm
    dm_key_map = {
        'name' => 'name',
        'en_name' => 'en_name',
        'logo' => 'logo',
        'intro' => 'org_des',
        'site' => 'url'
    }
    self.attributes.transform_keys {|k| dm_key_map[k]}.compact.merge(investor_type: 1)
  end

  def last_investevent
    #TODO order_by_date优化
    @last_investevent ||= Zombie::DmInvestevent.by_investor(self.id).order_by_date.limit(1).first
  end

  def last_ir_review
    self.ir_reviews.order(:created_at).last
  end

  def last_newsfeed
    self.newsfeeds.order(:created_at).last
  end

  def t_search_highlights
    unless self.respond_to?(:search_highlights)
      nil
    else
      self.search_highlights.transform_keys {|k| Organization.human_attribute_name(k)}
    end
  end

  def self.syn(id, include_member = true)
    organization = Organization.with_deleted.find_by_id(id) || Organization.new(id: id)
    raise '该机构不存在' unless organization
    dm_organization = nil
    Organization.transaction do
      if dm_organization = Zombie::DmInvestor.where(id: id).includes(:fromable)._select(:id, :name_without_prefix, :investor_des, :logo, :url, :investor_tags, :sectors, :invest_stages, :currencies).first
        organization.name = dm_organization.name_without_prefix
        organization.en_name = dm_organization.en_name
        organization.intro = dm_organization.investor_des
        organization.logo = dm_organization.logo
        organization.site = dm_organization.url
        organization.organization_tag_ids = dm_organization.investor_tags.map(&:id)
        organization.sector_ids = dm_organization.sectors.map(&:id)
        organization.invest_stage_ids = dm_organization.invest_stages.map(&:id)
        organization.currency_ids = dm_organization.currencies.map(&:id)
        organization.deleted_at = nil
        if organization.changed?
          organization.syn_at = Time.now
          organization.save!
        end
      end
    end

    if include_member && dm_organization
      Member.transaction do
        Zombie::DmMember.by_investor(id).includes(:person)._select(:id, :investor_id, :name_without_prefix, :en_name, :contact_email, :contact_tel, :weixin_url, :logo, :position_rank_id, :position, :address_id, :sectors, :currencies, :invest_stages, :is_dimission).each do |dm_member|
          Member.syn_by_dm_member(dm_member)
        end
      end
    end
  end

  def tag_desc
    self.tags.map(&:name)
  end

  def dm_organization
    @dm_organization ||= Zombie::DmInvestor.find(self.id)
  end

  def dm_investevent
    Zombie::DmInvestevent.by_investor(self.id)
  end

  def dm_investevent_relation
    Zombie::DmInvesteventInvestorRelation.where(investor_id: self.id)
  end

  def method_missing method, *args, &block
    return super method, *args, &block unless method.to_s =~ /^updated_at_of_\w+/
    attr = method.to_s[14..]
    self.class.send(:define_method, method) do
      #self.versions.where("object_changes ?| array[:column]", column: ['alias'])
      self.versions.where("object_changes ? :column", column: attr).order(:id).last&.created_at || self.updated_at
    end
    self.send method, *args, &block
  end

  def respond_to_missing?(method, *args)
    method.to_s =~ /^updated_at_of_\w+/ || super
  end
end
