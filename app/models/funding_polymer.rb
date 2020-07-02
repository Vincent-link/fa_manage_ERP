class FundingPolymer < ApplicationRecord
  self.table_name = 'fundings'

  acts_as_paranoid
  has_paper_trail
  searchkick

  include ModelState::FundingState

  belongs_to :company

  has_many :funding_normal_users, -> {kind_normal_users}, class_name: 'FundingUser', foreign_key: :funding_id
  has_many :normal_users, through: :funding_normal_users, source: :user

  has_many :funding_bd_leader, -> {kind_bd_leader}, class_name: 'FundingUser', foreign_key: :funding_id
  has_many :bd_leader, through: :funding_bd_leader, source: :user

  has_many :funding_execution_leader, -> {kind_execution_leader}, class_name: 'FundingUser', foreign_key: :funding_id
  has_many :execution_leader, through: :funding_execution_leader, source: :user

  has_many :funding_users, foreign_key: :funding_id
  has_many :funding_all_users, through: :funding_users, source: :user

  has_many :pipelines, foreign_key: :funding_id

  has_many :funding_members, through: :funding_users, source: :user

  scope :search_import, -> {includes(:company)}

  def search_data
    attributes.merge pipeline_status: self.pipelines.pluck(:status)
    # attributes.merge company: self.company
    # attributes.merge company_name: self.company&.name,
    #                  company_sector_names: self.company&.sector_ids.map { |ins| CacheBox.dm_single_sector_tree[ins] },
    #                  sector_ids: self.company&.sector_ids
    # todo 约见
    # todo Tracklog
  end

  def self.es_search(params)
    where_hash = {}
    if params[:location_ids]

    end

    if params[:sector_ids]

    end

    if params[:round_ids]
      where_hash[:round_id] = params[:round_ids]
    end

    #pipeline status
    where_hash[:pipeline_status] = {all: params[:pipeline_status]} if params[:pipeline_status].present?

    if params[:keyword]
      Funding.search(params[:keyword], where: where_hash, highlight: DEFAULT_HL_TAG.merge(fields: []))
    else
      Funding.search(where: where_hash)
    end
    # where_hash[:sector_ids] = {all: params[:sector]} if params[:sector].present?
    # where_hash[:round_ids] = {all: params[:round]} if !params[:any_round] && params[:round].present?
    # where_hash[:location_ids] = {all: params[:round]} if !params[:any_round] && params[:round].present?
    # todo 搜索还没好
    # Organization.search(params[:query], where: where_hash, order: order_hash, page: params[:page], per_page: params[:per_page], highlight: DEFAULT_HL_TAG)
  end
end
