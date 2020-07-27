class Pipeline < ApplicationRecord
  has_paper_trail
  include StateConfig
  include ModelSearch::PipelineSearch
  include ModelExport::PipelineExport
  include ModelStatistic::PipelineStatistic

  searchkick language: 'chinese'

  belongs_to :funding, class_name: 'FundingPolymer'

  has_many :pipeline_divides
  has_many :all_pipeline_divides, -> { with_deleted }, class_name: 'PipelineDivide'
  has_many :payments
  belongs_to :user, optional: true

  after_commit :reindex_funding
  before_create :generate_pipeline_name
  before_save :change_operating_day

  state_config :status, config: {
      n_ts_n_el: {value: 1, desc: '无TS（未签EL）', type: :without_ts, rate: 10},
      n_ts_el: {value: 2, desc: '无TS（已签EL）', type: :without_ts, rate: 10},
      tsing: {value: 3, desc: '有TS谈判中', type: :closing, rate: 25},
      tsed_dding: {value: 4, desc: '已签TS DD中', type: :closing, rate: 50},
      spaing: {value: 5, desc: 'SPA谈判中', type: :closing, rate: 75},
      spaed: {value: 6, desc: 'SPA已签署', type: :closing, rate: 90},
      closd: {value: 7, desc: '已交割', type: :closing, rate: 100},
      billed: {value: 8, desc: '已开账单', type: :completed, rate: 100},
      fee_ed: {value: 9, desc: '已收款', type: :completed, rate: 100},
      pending_n_el: {value: 10, desc: '终止（未签EL）', type: :pass, rate: 0},
      pending_el: {value: 11, desc: '终止（已签EL）', type: :pass, rate: 0},
  }

  state_config :total_fee_currency, config: {
    rmb: { value: 1, desc: 'RMD' },
    dollar: { value: 3, desc: 'USD' }
  }

  state_config :est_amount_currency, config: total_fee_currency_config

  delegate :status_desc, :status, :name, :category, :round_id, :is_list, :funding_source, :funding_source_desc, :updated_at, :operating_day, to: :funding, prefix: true
  delegate :name, to: :user, prefix: true, allow_nil: true

  scope :search_import, -> { includes(all_pipeline_divides: [:team, versions: :item], versions: :item ,funding: [:company, versions: :item]) }

  def search_data
    attributes.merge(
      version_pipeline: version_pipelines
    ).merge(funding.pipeline_es_import_data).merge(es_import_data).merge(divide_es_import_data)
  end

  def version_pipelines
    min_month_version = versions.min { |v| v.created_at }
    # 每月最后的versions
    month_versions = (min_month_version.created_at.to_s(:month)..Date.current.prev_month.to_s(:month)).inject({}) do |res, month|
      res.merge!(month => versions.select { |v| v.created_at.to_s(:month) <= month }.sort_by(&:created_at).last)
    end

    month_versions.inject([]) do |res, item|
      next_version = versions.select { |v| v.id > item.last.id }.first
      version_pipeline = next_version.present? ? next_version.reify : self
      date = "#{item.first}-01".to_date.end_of_month

      res << version_pipeline.attributes.merge(
        date: date
      ).merge(funding.pipeline_es_import_data(date)).merge(es_import_data(date)).merge(divide_es_import_data(date))
    end
  end

  # 指定日期的pipeline
  def version_pipeline(date = nil)
    return self if date.nil? || date.end_of_month == Date.current.end_of_month
    version = versions.select { |v| v.created_at.end_of_month.to_date <= date }.last
    next_version = versions.select { |v| v.id > version.id }.first
    next_version.present? ? next_version.reify : self
  end

  # 导入到es的数据
  def es_import_data(date = nil)
    {
      execution_day: execution_day,
      bu_rate: bu_rate(date),
      bu_total_fee_rmb: bu_total_fee_rmb(date),
      bu_rate_income_rmb: bu_rate_income_rmb(date),
      total_fee_rmb: total_fee_rmb(date),
      est_amount_rmb: est_amount_rmb(date),
      this_year_total_fee_rmb: this_year_total_fee_rmb(date),
      rate_total_fee_rmb: rate_total_fee_rmb(date),
      time_weight_income_rmb: time_weight_income_rmb(date),
      total_fee_usd: total_fee_usd(date),
      status_desc: version_pipeline(date).status_desc,
      last_updated_day: last_updated_day(date),
      est_amount_currency_desc: version_pipeline(date).est_amount_currency_desc,
      time_weight_rate: time_weight_rate(date),
      company_sector_ids: funding.company.sector_ids,
      company_sectors: company_sectors,
      total_fee: total_fee # TODO: total_fee有为nil的数据
    }
  end

  # pipeline_divide导入es数据
  def divide_es_import_data(date = nil)
    {
      funding_user_team_ids: version_pipeline_divides(date).map(&:team_id),
      funding_member_teams: funding_member_teams(date),
      divides: version_pipeline_divides(date).map { |divide| divide.slice(:id, :team_id, :team_name, :bu_id, :rate, :user_id, :user_name) }
    }
  end

  # TODO: total_fee有为nil的数据
  def total_fee
    self.read_attribute(:total_fee).nil? ? 0 : self.read_attribute(:total_fee)
  end

  def version_funding(date = nil)
    funding.version_funding(date)
  end

  # includes(:all_pipeline_divides)时查
  def version_pipeline_divides(date = nil)
    (date.nil? || date.end_of_month >= Date.today.end_of_month) ? all_pipeline_divides.select { |p_d| p_d.deleted_at.nil? } : all_pipeline_divides.map { |p_d| p_d.version_pipeline_divide(date) }.compact
  end

  # 本BU分成比例
  def bu_rate(date = nil)
    version_pipeline_divides(date).select(&:is_fa_bu?).map(&:rate).sum
  end

  # 本BU收费金额
  def bu_total_fee(date = nil)
    bu_rate(date) * version_pipeline(date).total_fee
  end

  # 年内概率收入
  def rate_total_fee(date = nil)
    (version_pipeline(date).complete_rate / 100.0) * version_pipeline(date).total_fee
  end

  # 年内预测收入
  def this_year_total_fee(date = nil)
    year = date.nil? ? Date.today.year : date.year
    version_pipeline(date).est_bill_date.year == year ? version_pipeline(date).total_fee : 0
  end

  def last_updated_day(date = nil)
    day = date.nil? ? Date.today : date.end_of_month
    (day - version_pipeline(date).updated_at.to_date).to_i
  end

  # 本BU概率收入
  def bu_rate_income(date = nil)
    bu_total_fee(date) * version_pipeline(date).complete_rate
  end

  def funding_member_teams(date = nil)
    version_pipeline_divides(date).map(&:team_name).uniq
  end

  def execution_day(date = nil)
    (version_pipeline(date).est_bill_date - version_pipeline(date).el_date).to_i
  end

  def pipeline_currency_rate(date = nil)
    version_pipeline(date).currency_rate.present? ? version_pipeline(date).currency_rate : ConfigBox.rmb_usd_rate
  end

  %w[est_amount total_fee bu_rate_income bu_total_fee rate_total_fee time_weight_income this_year_total_fee].each do |attr|
    # 转成RMB
    define_method "#{attr}_rmb" do |date = nil|
      if %w[total_fee bu_rate_income bu_total_fee rate_total_fee time_weight_income this_year_total_fee].include?(attr)
        version_pipeline(date).total_fee_currency_dollar? ? version_pipeline(date).send(attr) / pipeline_currency_rate(date) : version_pipeline(date).send(attr)
      else
        version_pipeline(date).send("#{attr}_currency_dollar?") ? version_pipeline(date).send(attr) / pipeline_currency_rate(date) : version_pipeline(date).send(attr)
      end
    end

    # 转成USD
    define_method "#{attr}_usd" do |date = nil|
      if %w[total_fee bu_rate_income bu_total_fee rate_total_fee time_weight_income this_year_total_fee].include?(attr)
        version_pipeline(date).total_fee_currency_dollar? ? version_pipeline(date).send(attr) : version_pipeline(date).send(attr) * pipeline_currency_rate(date)
      else
        version_pipeline(date).send("#{attr}_currency_dollar?") ? version_pipeline(date).send(attr) : version_pipeline(date).send(attr) * pipeline_currency_rate(date)
      end
    end
  end

  def company_sectors
    funding.company.sectors
  end

  def reindex_funding
    if self.saved_changes[:status].present?
      self.funding.reindex
    end
  end

  def divide= divide_arr = []
    divide_arr.each do |divide|
      self.pipeline_divides.find_or_initialize_by(user_id: divide[:user_id], bu_id: divide[:bu_id]) do |d|
        d.rate = divide[:rate]
      end
    end if divide_arr.present?
  end

  def generate_pipeline_name
    pipelines = self.funding.pipelines.order :created_at
    new_name = self.funding.category_pp? ? self.funding.round : self.funding.category_desc

    if self.funding.pipelines.size == 1
      self.name = new_name
    else
      self.name = "#{new_name}#{self.funding.pipelines.size + 1}"
      pipelines.each_with_index {|p, index| p.update name: "#{new_name}#{index + 1}"}
    end
  end

  def change_operating_day
    if status_changed?
      self.operating_day = Date.today
    end
  end

  # 时间加权
  def time_weight_rate(date = nil)
    date = date.nil? ? Date.today : date.end_of_month
    surplus_days = date.end_of_year.yday - date.yday
    status_avg_days = Pipeline.avg_days_to_close[version_pipeline(date).status]
    if surplus_days > status_avg_days * 0.8
      version_pipeline(date).status_rate
    elsif surplus_days < status_avg_days * 0.3
      0
    else
      version_pipeline(date).status_rate * ((surplus_days - status_avg_days * 0.3) / (status_avg_days * 0.5))
    end
  end

  def time_weight_income(date = nil)
    version_pipeline(date).total_fee * time_weight_rate(date) / 100
  end

  def self.unpass_status_values
    status_values - status_type_values(:pass)
  end

  def self.avg_days_to_close
    Rails.cache.fetch('avg_days_to_close', expires_in: 1.days) do
      Pipeline.status_values.map {|val| [val, 100 - 4 * val]}.to_h
    end
  end

  def self.reset_avg_days_to_close
    Rails.cache.delete('avg_days_to_close')
    self.avg_days_to_close
  end
end
