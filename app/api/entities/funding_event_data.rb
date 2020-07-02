module Entities
  class FundingEventData < Base
    expose :organization, with: Entities::IdName, documentation: {type: Entities::IdName, desc: '机构'}
    with_options(format_with: :time_to_s_date) do
      expose :pay_date, documentation: {type: 'date', desc: '结算日期'}
    end
    expose :amount, documentation: {type: 'string', desc: '投资金额'}
    expose :currency, documentation: {type: 'integer', desc: '币种'}
    expose :ratio, documentation: {type: 'integer', desc: '股份比例'}
  end
end