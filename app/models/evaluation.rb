class Evaluation < ApplicationRecord
  belongs_to :user
  belongs_to :funding

  has_many :questions, dependent: :destroy

  def get_number
    evaluations = Evaluation.where(funding_id: self.funding.id).where.not(id: self.id)
    row = 1
    evaluations.map do |e|
      row +=1 unless e.number.nil?
    end
    row
  end
end
