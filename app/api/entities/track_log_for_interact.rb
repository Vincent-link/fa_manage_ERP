module Entities
  class TrackLogForInteract < Base
    expose :id, documentation: {type: 'integer', desc: 'TrackLog id'}
    expose :status_desc, documentation: {type: 'string', desc: 'track_log状态'}
    expose :funding_id, documentation: {type: 'integer', desc: '项目id'}
    expose :funding_round_id, documentation: {type: 'integer', desc: '项目轮次'}
    expose :funding_name, documentation: {type: 'string', desc: '项目名称'}
    expose :funding_sector_id, documentation: {type: 'integer', desc: '项目行业id'}
    expose :funding_user_names, documentation: {type: 'string', desc: '项目参与人'}
    expose :member_names, documentation: {type: 'string', desc: '机构参与人'}
    expose :organization_id, documentation: {type: 'integer', desc: '机构id'}
    expose :organization_name, documentation: {type: 'string', desc: '机构名称'}
    expose :last_detail, using: Entities::TrackLogDetailLite, documentation: {type: Entities::TrackLogDetailLite, desc: '最近明细'}
  end
end