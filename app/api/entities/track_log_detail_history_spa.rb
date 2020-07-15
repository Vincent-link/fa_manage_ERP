module Entities
  class TrackLogDetailHistorySpa < Base
    expose :id, documentation: {type: 'integer', desc: 'SPA TrackLog id'}
    expose :pay_date, documentation: {type: 'string', desc: '结算日期'}
    expose :is_fee, documentation: {type: 'boolean', desc: '是否收费'}
    expose :fee_rate, documentation: {type: 'float', desc: '费率'}
    expose :fee_discount, documentation: {type: 'float', desc: '费率折扣'}
    expose :amount, documentation: {type: 'float', desc: '投资金额'}
    expose :currency, documentation: {type: 'integer', desc: '投资金额币种'}
    expose :ratio, documentation: {type: 'float', desc: '股权比例'}
    expose :file_spa, using: Entities::BlobFile, documentation: {type: Entities::BlobFile, desc: 'SPA文件'}
  end
end