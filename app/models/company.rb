class Company < ApplicationRecord
  has_many :calendars
  has_many :contacts, dependent: :destroy

  acts_as_taggable_on :tags
  acts_as_taggable_on :sectors


  has_one_attached :logo

  searchkick language: "chinese"
  scope :search_import, -> {includes(:calendars)}

  def search_data
    attributes.merge
  end

  def self.es_search(params)
    where_hash = {}
    where_hash[:sector_list] = {all: params[:sector_ids]} if params[:sector_ids].present?
    where_hash[:is_ka] = {all: params[:is_ka]} if params[:is_ka].present?
    where_hash[:recent_financing] = params[:recent_financing] if params[:recent_financing].present?

    order_hash = {}
    if params[:order_by]
      order_hash = {params[:order_by] => params[:order_type]}
    end

    Company.search(params[:query], where: where_hash, order: order_hash, page: params[:page], per_page: params[:per_page], highlight: DEFAULT_HL_TAG)
  end

  def financing_events
    @financing_events = Zombie::DmInvestevent.includes(:company, :invest_type, :invest_round).order_by_date.public_data.not_deleted.where(company_id: self.id).paginate(:page => 1, :per_page => 4)
    financing_events = []
    @financing_events.map do |e|
      financing_event = {}
      financing_event[:invest_type_and_batch_desc] = e.invest_type_and_batch_desc
      financing_event[:status] = e.status
      financing_event[:created_at] = e.created_at
      financing_events << financing_event
    end

    financing_events
  end
end
