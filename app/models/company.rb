class Company < ApplicationRecord
  has_many :calendars

  acts_as_taggable_on :tags
  acts_as_taggable_on :sub_tags
  acts_as_taggable_on :sectors


  has_one_attached :logo

  searchkick language: "chinese"
  scope :search_import, -> {includes(:calendars)}

  def search_data
    attributes.merge
  end

  def self.es_search(params)
    where_hash = {}
    binding.pry
    where_hash[:sector_list] = {all: params[:sector_ids]} if params[:sector_ids].present?
    where_hash[:is_ka] = {all: params[:is_ka]} if params[:is_ka].present?
    where_hash[:recent_financing] = params[:recent_financing] if params[:recent_financing].present?

    order_hash = {}
    if params[:order_by]
      order_hash = {params[:order_by] => params[:order_type]}
    end

    Company.search(params[:query], where: where_hash, order: order_hash, page: params[:page], per_page: params[:per_page], highlight: DEFAULT_HL_TAG)
  end

end
