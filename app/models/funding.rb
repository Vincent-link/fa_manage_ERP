class Funding < ApplicationRecord
  belongs_to :company

  has_many :time_lines
  has_many :funding_company_contacts

  has_many :funding_users
end
