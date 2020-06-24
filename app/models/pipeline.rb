class Pipeline < ApplicationRecord
  include StateConfig

  belongs_to :funding

  has_many :pipeline_divides
  has_many :payments

  after_commit :reindex_funding

  state_config :status, config: {
      new: {value: 1, desc: '未约见'},
      meet: {value: 2, desc: '已约见'},
      done: {value: 3, desc: '已完成'},
      cancel: {value: 4, desc: '已取消'}
  }

  delegate :status_desc, to: :funding, prefix: true

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
end
