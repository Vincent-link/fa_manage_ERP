module Entities
  class FundingComprehensive < Base
    expose :funding, merge: true do |ins|
      Entities::Funding.represent ins
    end


  end
end