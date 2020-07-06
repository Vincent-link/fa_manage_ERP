module Entities
  class FundingComprehensive < Base
    expose :funding, documentation: {type: Entities::Funding, desc: '项目', merge: true}, merge: true do |ins|
      Entities::Funding.represent ins.includes(:verifications)
    end
    # expose :funding_company_contacts, with: Entities::FundingCompanyContact, documentation: {type: Entities::FundingCompanyContact, desc: '团队成员', is_array: true}
    expose :time_lines, with: Entities::TimeLine, documentation: {type: Entities::TimeLine, desc: '状态变更历史', is_array: true}
    expose :funding_materials, using: Entities::File, documentation: {type: Entities::File, desc: '附件', is_array: true}
    # todo 项目BP
    # todo 工商信息
  end
end