module Entities
  class FundingComprehensive < Base
    expose :funding, merge: true do |ins|
      Entities::Funding.represent ins
    end
    expose :funding_company_contacts, with: Entities::FundingCompanyContact, documentation: {type: 'Entities::FundingCompanyContact', desc: '团队成员'}
    expose :time_lines, with: Entities::TimeLine, documentation: {type: 'Entities::TimeLine', desc: '状态变更历史'}
    # todo 融资历史
  end
end