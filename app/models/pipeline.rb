class Pipeline < ApplicationRecord
  has_paper_trail
  include StateConfig

  belongs_to :funding, class_name: 'FundingPolymer'

  has_many :pipeline_divides
  has_many :payments
  belongs_to :user, optional: true

  after_commit :reindex_funding
  before_create :generate_pipeline_name

  state_config :status, config: {
      n_ts_n_el: {value: 1, desc: '无TS（未签EL）'},
      n_ts_el: {value: 2, desc: '无TS（已签EL）'},
      tsing: {value: 3, desc: '有TS谈判中'},
      tsed: {value: 4, desc: '已签TS'},
      dding: {value: 5, desc: 'DD中'},
      spaing: {value: 6, desc: 'SPA谈判中'},
      spaed: {value: 7, desc: 'SPA已签署'},
      closd: {value: 8, desc: '已交割'},
      billed: {value: 9, desc: '已开账单'},
      fee_ed: {value: 10, desc: '已收款'},
      pending_n_el: {value: 11, desc: '终止（未签EL）'},
      pending_el: {value: 12, desc: '终止（已签EL）'},
  }

  delegate :status_desc, to: :funding, prefix: true
  delegate :name, to: :user, prefix: true, allow_nil: true

  def reindex_funding
    if self.saved_changes[:status].present?
      self.funding.reindex
    end
  end

  def divide= divide_arr = []
    divide_arr.each do |divide|
      self.pipeline_divides.find_or_initialize_by user_id: divide[:user_id] do |d|
        d.rate = divide[:rate]
      end
    end if divide_arr.present?
  end

  def generate_pipeline_name
    pipelines = self.funding.pipelines.order :created_at
    if self.funding.pipelines.size == 1
      self.name = self.funding.round
    else
      self.name = "#{self.funding.round}#{self.funding.pipelines.size + 1}"
      pipelines.each_with_index {|p, index| p.update name: "#{self.funding.round}#{index + 1}"}
    end
  end
end
