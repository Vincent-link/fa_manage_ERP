class Question < ApplicationRecord
  has_many :answers

  belongs_to :evaluation
  belongs_to :user
end
