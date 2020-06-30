class Address < ApplicationRecord
  acts_as_paranoid

  scope :customer, -> {where.not(id: 100000)}

  def self.huaxing_office
    self.find 100000
  end
end
