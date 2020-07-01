class Kpi < ApplicationRecord
  belongs_to :kpi_group
  has_many :conditions, class_name: "Kpi", foreign_key: :parent_id
end
