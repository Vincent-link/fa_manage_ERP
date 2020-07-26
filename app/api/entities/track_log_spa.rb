module Entities
  class TrackLogSpa < Base
    expose :id, documentation: {type: 'integer', desc: 'TrackLog id'}
    expose :pay_date, documentation: {type: 'string', desc: '结算日期'}
    expose :is_fee, documentation: {type: 'boolean', desc: '是否收费'}
    expose :fee_rate, documentation: {type: 'float', desc: '费率'}
    expose :fee_discount, documentation: {type: 'float', desc: '费率折扣'}
    expose :amount, documentation: {type: 'float', desc: '投资金额'}
    expose :currency, documentation: {type: 'integer', desc: '币种'}
    expose :ratio, documentation: {type: 'float', desc: '股份比例'}
    expose :file_spa_attachment, as: :file_spa, using: Entities::Attachment, documentation: {type: Entities::Attachment, desc: 'spa文件', required: true}
    expose :members, with: Entities::MemberLite, documentation: {type: Entities::MemberLite, desc: '投资人', is_array: true}
    expose :organization, with: Entities::OrganizationForSelect, documentation: {type: Entities::OrganizationForSelect, desc: '机构'}
  end
end