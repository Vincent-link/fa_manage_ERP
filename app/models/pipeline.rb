class Pipeline < ApplicationRecord
  belongs_to :funding

  has_many :pipeline_divides
  has_many :payments

  def divide= divide_arr = []
    divide_arr.each do |divide|
      self.pipeline_divides.find_or_initialize_by user_id: divide[:user_id] do |d|
        d.rate = divide[:rate]
      end
    end
  end
end
