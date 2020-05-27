class Funding < ApplicationRecord
  belongs_to :company

  has_many :time_lines
  has_many :funding_company_contacts

  has_many :funding_users

  has_many :evaluations
  has_many :questions

  def investment_committee_ids=(*ids)
    self.evaluations.delete_all
    ids.flatten.each do |id|
      add_investment_committee_by_id id
    end
  end

  def add_investment_committee_by_id id
    self.evaluations.find_or_create_by :user_id => id
  end

  def delete_investment_committee_by_id id
    self.evaluations.find_by(user_id: id).destroy
  end
end
