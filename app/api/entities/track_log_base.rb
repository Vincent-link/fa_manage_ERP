module Entities
  class TrackLogBase < Base
    expose :id, documentation: {type: 'integer', desc: 'TrackLog id'}
    expose :status, documentation: {type: Entities::IdName, desc: '状态'} do |ins|
      {
          id: ins.status,
          name: ins.status_desc
      }
    end

    expose :has_bp, documentation: {type: 'boolean', desc: '是否上传bp'}
    expose :has_nda, documentation: {type: 'boolean', desc: '是否上传nda'}
    expose :has_teaser, documentation: {type: 'boolean', desc: '是否上传teaser'}
    expose :has_model, documentation: {type: 'boolean', desc: '是否上传model'}
    expose :track_log_detail, documentation: {type: Entities::TrackLogDetail, desc: '跟进信息'} do |ins|
      Entities::TrackLogDetail.represent ins.track_log_details.first
    end
    expose :members, with: Entities::MemberLite, documentation: {type: Entities::MemberLite, desc: '投资人', is_array: true}
    expose :organization, with: Entities::OrganizationForSelect, documentation: {type: Entities::OrganizationForSelect, desc: '机构'}

    expose :pay_date, if: lambda { |ins| ins.status_spa_sha?}, documentation: {type: 'date', desc: '结算日期'}
    expose :is_fee, if: lambda { |ins| ins.status_spa_sha?}, documentation: {type: 'boolean', desc: '是否收费'}
    expose :fee_rate, if: lambda { |ins| ins.status_spa_sha?}, documentation: {type: 'float', desc: '费率'}
    expose :fee_discount, if: lambda { |ins| ins.status_spa_sha?}, documentation: {type: 'float', desc: '费率折扣'}
    expose :amount, if: lambda { |ins| ins.status_spa_sha?}, documentation: {type: 'float', desc: '投资金额'}
    expose :currency, if: lambda { |ins| ins.status_spa_sha?}, documentation: {type: 'integer', desc: '投资金额币种'}
    expose :ratio, if: lambda { |ins| ins.status_spa_sha?}, documentation: {type: 'float', desc: '股权比例'}

    expose :file_spa_attachment, as: :file_spa, using: Entities::File, if: lambda { |ins| ins.status_spa_sha?}, documentation: {type: Entities::File, desc: 'SPA文件'}
    expose :file_ts_attachment, as: :file_ts, using: Entities::File, if: lambda { |ins| ins.status_issue_ts?}, documentation: {type: Entities::File, desc: 'TS文件'}

    expose :has_spa, documentation: {type: 'boolean', desc: '是否有spa'} do |ins|
      ins.file_spa.present?
    end
    expose :has_ts, documentation: {type: 'boolean', desc: '是否有ts'} do |ins|
      ins.file_ts.present?
    end
    expose :has_calender, documentation: {type: 'boolean', desc: '是否有会议'} do |ins|
      ins.calenders.present?
    end
  end
end