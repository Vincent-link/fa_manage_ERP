class Member < ApplicationRecord
  acts_as_paranoid
  has_paper_trail
  searchkick language: "chinese"
  include StateConfig

  state_config :report_type, config: {
      solid: {value: 1, desc: '实线汇报'},
      virtual: {value: 2, desc: '虚线汇报'},
  }

  #todo after_create to dm

  belongs_to :organization, optional: true
  belongs_to :sponsor, class_name: 'User', optional: true

  has_many :member_user_relations
  has_many :users, through: :member_user_relations

  delegate :name, to: :organization, prefix: true

  [:address, :report_relations].each do |attribute_name|
    define_method(attribute_name) do
      dm_member.send(attribute_name)
    end
  end

  def dm_member
    @dm_member ||= Zombie::DmMember.find(self.id)
  end

  def dm_lower_report_relation
    @lower_report_relation ||= Zombie::DmMemberReportRelation.where(superior_id: self.id).inspect
  end

  def self.es_search(params)
    where_hash = {}
    where_hash[:sector_ids] = {all: params[:sector]}
    where_hash[:round_ids] = {all: params[:round]}
    where_hash[:currency_ids] = {all: params[:currency]}
    where_hash[:level] = params[:level] if params[:level].present?
    where_hash[:scale_ids] = params[:scale] if params[:scale].present?
    where_hash[:position_rank_id] = params[:position_rank_id] if params[:position_rank_id]
    if params[:amount_min].present? || params[:amount_max].present?
      range = (params[:amount_min] || 0)..(params[:amount_max] || 9999999)
      where_hash[:_or] = [{usd_amount_min: range}, {usd_amount_max: range}]
    end
    if params[:investor_group_id] || params[:followed]
      where_hash[:id] = (InvestorGroup.find(params[:investor_group_id]).member_ids & current_user.follows.member.pluck(:id))
    end
    #todo association

    Member.search(params[:query], where: where_hash, page: params[:page], per_page: params[:per_page], highlight: DEFAULT_HL_TAG)
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
      if dm_member = Zombie::DmMember.where(id: id).includes(:person)._select(:id, :investor_id, :name, :en_name, :contact_email, :contact_tel, :weixin_url, :logo, :team, :position_rank_id, :position, :address_id, :sectors, :currencies, :invest_stages, :is_dimission).first
        Member.syn_by_dm_member dm_member
      end
    end
  end
end
