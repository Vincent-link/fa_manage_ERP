class Company < ApplicationRecord
  include BlobFileSupport

  has_many :calendars
  has_many :contacts, dependent: :destroy
  has_many :fundings, dependent: :destroy

  acts_as_taggable_on :company_tags

  has_one_attached :logo
  has_blob_upload :logo

  searchkick language: "chinese"
  scope :search_import, -> {includes(:calendars)}

  validates_presence_of :name
  validates_presence_of :one_sentence_intro
  validates_presence_of :location_province_id
  validates_presence_of :location_city_id

  after_validation :save_to_dm

  def save_to_dm
    if self.new_record?
      company = Zombie::DmCompany.create_company self.attributes_for_dm
      self.id = company.id
    end
  end

  def attributes_for_dm
    dm_key_map = {
        'name' => 'name',
        'en_name' => 'en_name',
        'sector_id' => 'sub_category_id',
        'parent_sector_id' => 'category_id',
        'location_city_id' => 'location_city_id',
        'location_province_id' => 'location_province_id',
        'detailed_intro' => 'com_des',
        'website' => 'url',
        'detailed_intro' => 'com_des',
        'registered_name' => 'registered_name',
    }
    self.attributes.transform_keys {|k| dm_key_map[k]}.compact
  end

  # def search_data
  #   # attributes.merge sector_ids: self.sector_ids
  # end

  def self.es_search(params)
    where_hash = {}
    where_hash[:sector_ids] = {all: params[:sector_ids]} if params[:sector_ids].present?
    where_hash[:is_ka] = params[:is_ka] if !params[:is_ka].nil?
    where_hash[:recent_financing] = {all: params[:recent_financing_ids]} if params[:recent_financing_ids].present?
    order_hash = {"updated_at" => "desc"}
    # if params[:order_by]
    #   order_hash = {params[:order_by] => params[:order_type]}
    # end

    Company.search(params[:query], match: :phrase, where: where_hash, order: order_hash, page: params[:page], per_page: params[:per_page], highlight: DEFAULT_HL_TAG)
  end

  def financing_events(kun=nil)
    all_events = []
    # 公司详情融资历史是需要加上kun数据
    if kun.nil?
      self_financing_events = self.fundings
      financing_events = Zombie::DmInvestevent.includes(:company, :invest_type, :invest_round, :investors, :investevent_investor_relations).order_by_date.public_data.not_deleted.where(company_id: self.id)
      ._select(:id, :all_investors, :birth_date, :invest_type_and_batch_desc, :detail_money_des, :invest_round_id, :investment_money, :investment_money_unit, :investment_ratio)
      all_events = (financing_events + self_financing_events).sort_by {|p| (p.try(:round_id) || p.try(:invest_round_id)).to_i}.reverse
    # 首页创建项目搜索公司时，不需要kun融资数据
    else
      all_events = self.fundings.order(round_id: :desc)
    end

    arr = []
    all_events.map do |event|
      event_hash = {}
      if event.class.name == "Funding"
        event_hash[:id] = event.id
        event_hash[:date] = event.updated_at
        event_hash[:round_id] = event.round_id
        # 融资额
        event_hash[:target_amount] = get_fa_target_amount(event)

        if event.status == Funding.status_pass_value
          event_hash[:funding_members] = "pass理由：#{event.time_lines.pluck(:reason).join("。")}"
        else
          event_hash[:funding_members] = event.funding_members.pluck(:name).join("、")
        end
        event_hash[:organizations] = fa_member_details(event)
        event_hash[:status] = Funding.status_desc_for_value(event.status)
      else
        event_hash[:id] = event.id
        event_hash[:date] = Time.parse(event.birth_date)
        event_hash[:round_id] = event.invest_round_id
        event_hash[:target_amount] = event.detail_money_des
        event_hash[:organizations] = data_server_member_details(event)
        event_hash[:status] = "融资事件"
      end
      arr << event_hash
    end
    arr
  end

  def recent_financing
    self_financing_events = self.fundings
    financing_events = Zombie::DmInvestevent.includes(:company, :invest_type, :invest_round, :investors).order_by_date.public_data.not_deleted.where(company_id: self.id)._select(:id, :all_investors, :birth_date, :invest_type_and_batch_desc, :detail_money_des, :invest_round_id)
    all_events = (financing_events + self_financing_events).sort_by {|p| (p.try(:round_id) || p.try(:invest_round_id)).to_i}.reverse

    if all_events.empty?
      "-"
    else
      "#{all_events&.first.try(:invest_type_and_batch_desc) || get_fa_round_name(all_events.first&.try(:round_id))}-#{all_events&.first.try(:detail_money_des) || get_fa_target_amount(all_events.first)}"
    end
  end

  def syn_recent_financing
    financing_events = Zombie::DmInvestevent.includes(:company, :invest_type, :invest_round).public_data.not_deleted.where(company_id: self.id)._select(:invest_round_id, :invest_type_id).sort_by(&:birth_date)
    invest_types = Zombie::DmInvestType.all
    if !financing_events.empty?
      # 如果融资为私募或新三板的话，使用轮次；如果否的话，轮次是nil，使用融资类型表示
      if !financing_events.last.try(:invest_round_id).nil?
        self.recent_financing = financing_events.last.try(:invest_round_id)
      else
        self.recent_financing = invest_types.find {|e| e.id == financing_events.last.try(:invest_type_id)}.id
      end
    end

    self.save!
  end

  def syn_root_sector(sector_id)
    parent_sector_id = CacheBox::dm_sector_tree.select{|e| e["children"].select{|e| e["id"] == sector_id}.present?}&.first["id"] if CacheBox::dm_sector_tree.select{|e| e["children"].select{|e| e["id"] == sector_id}.present?}&.first.present?
    Zombie::DmCompany.filter(id: self.id).last.update(category_id: parent_sector_id)
    self.parent_sector_id = parent_sector_id
    self.save!
  end

  # 获取fa项目融资轮次名称
  def get_fa_round_name(round_id)
    CacheBox::dm_rounds.select { |e| e["id"] == round_id }&.first["name"] if CacheBox::dm_rounds.select { |e| e["id"] == round_id }&.first.present?
  end

  # 获取fa项目融资轮次融资额
  def get_fa_target_amount(event)
    target_amount_currency_arr = CacheBox::dm_currencies.select { |e| e["id"] == event.target_amount_currency }
    target_amount_currency = ""
    target_amount_currency = target_amount_currency_arr.first["name"] unless target_amount_currency_arr.empty?
    target_amount = event.target_amount/10000 unless event.target_amount.nil?
    "#{target_amount}万#{target_amount_currency}"
  end

  def data_server_member_details(event)
    arr = []
    event.all_investors.map do |investor|
      row = {}
      row[:investor_name] = investor.name
      row[:investment_money] = investor&.investevent_investor_relation&.investment_money * investor&.investevent_investor_relation&.investment_money_unit
      row[:investment_ratio] = investor&.investevent_investor_relation&.investment_ratio
      row[:currency_id] = event.currency_id
      arr << row
    end
    arr
  end

  def fa_member_details(event)
    arr = []
    event.spas.map do |spa|
      row = {}
      row[:investor_name] = spa.organization&.name if spa.present?
      row[:nvestment_money] = spa.amount
      row[:investment_ratio] = spa.ratio
      row[:currency_id] = spa.currency
      arr << row
    end
    arr
  end
end
