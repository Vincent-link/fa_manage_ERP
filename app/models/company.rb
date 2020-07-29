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

  validates_presence_of :name, unless: :is_kun
  validates_presence_of :one_sentence_intro, unless: :is_kun
  validates_presence_of :location_province_id, unless: :is_kun
  validates_presence_of :location_city_id, unless: :is_kun

  attr_accessor :blob_id

  after_validation :save_to_dm
  before_save :syn_root_sector

  def save_to_dm
    if self.is_kun.nil?
      if self.blob_id.present?
        blob = ActiveStorage::Blob.find(self.blob_id)
        self.logo_url = blob.service_url
      end

      if self.new_record?
        dm_company = Zombie::DmCompany.create_company self.attributes_for_dm
        self.id = dm_company.id
      else
        Zombie::DmCompany.find(self.id).update self.attributes_for_dm
      end
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
        'registered_name' => 'registered_name',
        'logo_url' => 'logo',
    }
    self.attributes.transform_keys {|k| dm_key_map[k]}.compact
  end

  def search_data
    attributes.merge calendar_summary: "#{self.calendars.map(&:summary).join(' ')}",
                     calendar_summary_detail: "#{self.calendars.map(&:summary_detail).join(' ')}",
                     cat_round_date_rate: is_chance
  end

  def sector_ids
    [sector_id, parent_sector_id].compact
  end

  def sectors
    CacheBox.dm_single_sector_tree.slice(*sector_ids).values
  end

  def self.es_search(params)
    where_hash = {}
    params[:query] = '*' if params[:query].blank?
    where_hash[:parent_sector_id] = params[:sector_ids] if params[:sector_ids].present?
    where_hash[:is_ka] = params[:is_ka] if !params[:is_ka].nil?
    where_hash[:recent_financing] = params[:recent_financing_ids] if params[:recent_financing_ids].present?
    where_hash[:cat_round_date_rate] = Settings.company.invest_rate_min..Settings.company.invest_rate_max if params[:is_chance]

    order_hash = {}
    # if params[:order_by]
    #   order_hash = {params[:order_by] => params[:order_type]}
    # end

    Company.search(params[:query], fields: [:name, :parent_sector_id, :one_sentence_intro, :detailed_intro, :calendar_summary, :calendar_summary_detail, :cat_round_date_rate], where: where_hash, order: order_hash, page: params[:page], per_page: params[:per_page], highlight: DEFAULT_HL_TAG)
  end

  def tc_search_highlights
    unless self.respond_to?(:search_highlights)
      nil
    else
      self.search_highlights.transform_keys {|k| Company.human_attribute_name(k)}
    end
  end

  def financing_events(kun=nil)
    all_events = []
    # 公司详情融资历史是需要加上kun数据
    if kun.nil?
      self_financing_events = self.fundings
      financing_events = Zombie::DmInvestevent.includes(:company, :invest_type, :invest_round, :investors, :investevent_investor_relations).order_by_date.not_deleted.search(company_id: self.id)
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
          event_hash[:pass_reason] = event.time_lines.last.reason
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

  # 创建公司时，把一级行业保存下来
  def syn_root_sector
    parent_sector_id = CacheBox::dm_sector_tree.select{|e| e["children"].select{|e| e["id"] == self.sector_id}.present?}&.first["id"] if CacheBox::dm_sector_tree.select{|e| e["children"].select{|e| e["id"] == self.sector_id}.present?}&.first.present?

    Zombie::DmCompany.filter(id: self.id).last.update(category_id: parent_sector_id)
    self.parent_sector_id = parent_sector_id
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

  # dataserver 投资机构 占股比例
  def data_server_member_details(event)
    arr = []
    if event.all_investors.present?
      event.all_investors.map do |investor|
        row = {}
        row[:investor_name] = investor.name
        row[:investment_money] = investor&.investevent_investor_relation&.investment_money_unit.present? ? investor&.investevent_investor_relation&.investment_money.to_i * investor&.investevent_investor_relation&.investment_money_unit : investor&.investevent_investor_relation&.investment_money.to_i
        row[:investment_ratio] = investor&.investevent_investor_relation&.investment_ratio
        row[:currency_id] = event.currency_id
        arr << row
      end
    end
    arr
  end

  # fa 投资机构 占股比例
  def fa_member_details(event)
    arr = []
    event.spas.map do |spa|
      row = {}
      row[:investor_name] = spa.organization&.name if spa.present?
      row[:investment_money] = spa.amount
      row[:investment_ratio] = spa.ratio
      row[:currency_id] = spa.currency
      arr << row
    end
    arr
  end

  def self.syn(id)
    company = Company.find_by_id(id) || Company.new(id: id)
    raise '该公司不存在' unless company

    Company.transaction do
      if dm_company = Zombie::DmCompany.where(id: id).first
        company.name = dm_company.name
        company.one_sentence_intro = dm_company.slogan if company.one_sentence_intro.nil?
        # 如果fa这边公司的logo是用户上传的，就不同步了
        company.logo_url = dm_company.logo if company.logo_attachment.nil?
        company.sector_id = dm_company.sub_category_id

        company.parent_sector_id = dm_company.category_id
        company.location_city_id = dm_company.location_city_id
        company.location_province_id = dm_company.location_province_id
        company.detailed_intro = dm_company.com_des if company.detailed_intro.nil?
        company.website = dm_company.url

        company.registered_name = dm_company.registered_name
        company.created_at = dm_company.created_at
        company.updated_at = dm_company.updated_at
        if company.changed?
          company.syn_at = Time.now
          company.is_kun = true
          company.save!
        end
      end
    end
  end

  # def Zombie.syn_recent_financing(dm_cpmany_id)
  #   financing_events = Zombie::DmInvestevent.includes(:company, :invest_type, :invest_round).public_data.not_deleted.where(company_id: dm_cpmany_id)._select(:invest_round_id, :invest_type_id).sort_by(&:birth_date)
  #   invest_types = Zombie::DmInvestType.all
  #   if !financing_events.empty?
  #     # 如果融资为私募或新三板的话，使用轮次；如果否的话，轮次是nil，使用融资类型表示
  #     if !financing_events.last.try(:invest_round_id).nil?
  #       recent_financing = financing_events.last.try(:invest_round_id)
  #     # else
  #     #   self.recent_financing = invest_types.find {|e| e.id == financing_events.last.try(:invest_type_id)}.try(:id)
  #     end
  #   end
  # end

  # 日历约见已完成
  def callreport_num
    self.calendars.where(status: Calendar.status_done_value).count
  end

  # 是否具有潜在融资需求
  def is_chance
    Zombie::DmCompany.find_by_id(self.id)&.overview&.cat_round_date_rate.to_f
  end

  # 创建公司之后，和blob建立关联
  def save_logo(logo_params)
    if logo_params.present? && logo_params[:blob_id].present?
      ActiveStorage::Attachment.create!(name: 'logo', record_type: 'Company', record_id: self.id, blob_id: logo_params[:blob_id])
    end
  end

  def create_contact(contacts_params)
    contacts_params.map { |e| Contact.create!(e.merge(company_id: self.id)) } if contacts_params.present?
  end
end
