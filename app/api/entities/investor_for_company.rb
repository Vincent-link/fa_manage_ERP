module Entities
  class InvestorForCompany < Base
    expose :investor_name, documentation: {type: 'string', desc: '投资机构名称'}
    expose :investment_money, documentation: {type: 'string', desc: '投资金额'}
    expose :investment_ratio, documentation: {type: 'string', desc: '占股比例'}
    expose :currency_id, documentation: {type: 'string', desc: '币种'}
  end
end
