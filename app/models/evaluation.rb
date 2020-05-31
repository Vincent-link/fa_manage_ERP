class Evaluation < ApplicationRecord
  belongs_to :user
  belongs_to :funding

  has_many :questions, dependent: :destroy
end
