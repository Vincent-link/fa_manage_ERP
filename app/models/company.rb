class Company < ApplicationRecord
  has_many :calendars
  has_many :contacts, dependent: :destroy
  has_many :fundings

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

    order_hash = {"updated_at" => "desc"}
    # if params[:order_by]
    #   order_hash = {params[:order_by] => params[:order_type]}
    # end

    Company.search(params[:query], where: where_hash, order: order_hash, page: params[:page], per_page: params[:per_page], highlight: DEFAULT_HL_TAG)
  end

  def financing_events
    self_financing_events = self.fundings
    financing_events = Zombie::DmInvestevent.includes(:company, :invest_type, :invest_round, :investors).order_by_date.public_data.not_deleted.where(company_id: self.id).paginate(:page => 1, :per_page => 4)._select(:all_investors, :birth_date, :invest_type_and_batch_desc, :detail_money_des)
    all_events = (financing_events + self_financing_events).sort_by {|p| p.try(:birth_date) || p.try(:updated_at)}.reverse

    all_events.map do |event|
      event_hash = {}
      if event.class.name == "Funding"
        event_hash[:date] = event.updated_at
        event_hash[:round_id] = event.round_id
        event_hash[:target_amount] = event.target_amount
        if self.status == 9
          event_hash[:funding_members] = self.time_lines.pluck(:reason)
        else
          event_hash[:funding_members] = event.funding_members
        end
        event_hash[:status] = event.status
      else
        event_hash[:date] = event.birth_date
        event_hash[:round_id] = event.invest_type_and_batch_desc
        event_hash[:target_amount] = event.detail_money_des
        event_hash[:funding_members] = event.funding_members
        event_hash[:status] = "融资事件"
      end

    end
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
