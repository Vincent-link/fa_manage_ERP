class Company < ApplicationRecord
  include BlobFileSupport

  has_many :calendars
  has_many :contacts, dependent: :destroy
  has_many :fundings, dependent: :destroy

  acts_as_taggable_on :company_tags
  acts_as_taggable_on :sectors

  has_one_attached :logo
  has_blob_upload :logo

  searchkick language: "chinese"
  scope :search_import, -> {includes(:calendars)}

  validates_presence_of :name
  validates_presence_of :one_sentence_intro
  validates_presence_of :location_province_id
  validates_presence_of :location_city_id

  def search_data
    attributes.merge sector_ids: self.sectors.ids
  end

  def self.es_search(params)
    where_hash = {}
    where_hash[:sector_ids] = params[:sector_ids] if params[:sector_ids].present?
    where_hash[:is_ka] = params[:is_ka] if !params[:is_ka].nil?
    where_hash[:recent_financing] = params[:recent_financing] if params[:recent_financing].present?

    order_hash = {"updated_at" => "desc"}
    # if params[:order_by]
    #   order_hash = {params[:order_by] => params[:order_type]}
    # end

    Company.search(params[:query], where: where_hash, order: order_hash, page: params[:page], per_page: params[:per_page], highlight: DEFAULT_HL_TAG)
  end

  def financing_events
    self_financing_events = self.fundings
    financing_events = Zombie::DmInvestevent.includes(:company, :invest_type, :invest_round, :investors).order_by_date.public_data.not_deleted.where(company_id: self.id).paginate(:page => 1, :per_page => 4)._select(:id, :all_investors, :birth_date, :invest_type_and_batch_desc, :detail_money_des)
    all_events = (financing_events + self_financing_events).sort_by {|p| p.try(:round_id) || p.try(:invest_round_id)}

    arr = []
    all_events.map do |event|
      event_hash = {}
      if event.class.name == "Funding"
        event_hash[:id] = event.id
        event_hash[:date] = event.updated_at
        event_hash[:round_id] = event.round_id

        target_amount_currency_arr = CacheBox::dm_currencies.select { |e| e["id"] == event.target_amount_currency }
        target_amount_currency = ""
        target_amount_currency = target_amount_currency_arr.first["name"] unless target_amount_currency_arr.empty?
        target_amount = event.target_amount/10000 unless event.target_amount.nil?
        event_hash[:target_amount] = "#{target_amount}万#{target_amount_currency}"

        if event.status == Funding.status_pass_value
          event_hash[:funding_members] = "pass理由：#{event.time_lines.pluck(:reason).join("。")}"
        else
          event_hash[:funding_members] = event.funding_members.pluck(:name).join("、")
        end
        event_hash[:status] = Funding.status_desc_for_value(event.status)
      else
        event_hash[:id] = event.id
        event_hash[:date] = Time.parse(event.birth_date)
        event_hash[:round_id] = event.invest_type_and_batch_desc
        event_hash[:target_amount] = event.detail_money_des
        event_hash[:funding_members] = event.all_investors.pluck(:fromable_name).join("、")
        event_hash[:status] = "融资事件"
      end
      arr << event_hash
    end
    arr
  end

  def recent_financing
    financing_events = Zombie::DmInvestevent.includes(:company, :invest_type, :invest_round).public_data.not_deleted.where(company_id: self.id)._select(:invest_type_and_batch_desc, :detail_money_des, :birth_date).sort_by(&:birth_date)
    if financing_events.empty?
      "-"
    else
      "#{financing_events.last.invest_type_and_batch_desc}-#{financing_events.last.detail_money_des}"
    end
  end
end
