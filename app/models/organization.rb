class Organization < ApplicationRecord
  acts_as_paranoid
  has_paper_trail
  searchkick

  include StateConfig

  has_many :members
  has_many :comments, as: :commentable
  has_many :ir_reviews, as: :commentable
  has_many :newsfeeds, as: :commentable

  #todo after_create to dm

  delegate :addresses, to: :dm_organization, prefix: false

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

  def self.es_search(params)
    where_hash = {}
    where_hash[:sector_ids] = {all: params[:sector]}
    where_hash[:round_ids] = {all: params[:round]}
    where_hash[:currency_ids] = {all: params[:currency]}
    where_hash[:level] = params[:level] if params[:level].present?
    if params[:amount_min].present? || params[:amount_max].present?
      range = (params[:amount_min] || 0)..(params[:amount_max] || 9999999)
      where_hash[:_or] = [{usd_amount_min: range}, {usd_amount_max: range}]
    end
    if params[:investor_group_id]
      where_hash[:id] = InvestorGroup.find(params[:investor_group_id]).organization_ids
    end
    #todo association

    Organization.search(params[:query], where: where_hash, page: params[:page], per_page: params[:per_page], highlight: DEFAULT_HL_TAG)
  end

  def last_investevent
    #TODO order_by_date优化
    @last_investevent ||= Zombie::DmInvestevent.by_investor(self.id).order_by_date.limit(1).first
  end

  def better_search_highlights
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
        organization.tag_ids = dm_organization.investor_tags.map(&:id)
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
        Zombie::DmMember.by_investor(id).includes(:person)._select(:id, :investor_id, :name_without_prefix, :en_name, :contact_email, :contact_tel, :weixin_url, :logo, :team, :position_rank_id, :position, :address_id, :sectors, :currencies, :invest_stages, :is_dimission).each do |dm_member|
          Member.syn_by_dm_member(dm_member)
        end
      end
    end
  end

  def dm_organization
    @dm_organization ||= Zombie::DmInvestor.find(self.id)
  end

  def dm_investevent
    Zombie::DmInvestevent.by_investor(self.id)
  end
end
