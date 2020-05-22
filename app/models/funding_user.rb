class FundingUser < ApplicationRecord
  belongs_to :funding
  belongs_to :user
end
