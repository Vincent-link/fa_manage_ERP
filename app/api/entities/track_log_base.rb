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
    expose :track_log_detail, with: Entities::TrackLogDetail, documentation: {type: Entities::TrackLogDetail, desc: '跟进信息'} do |ins|
      Entities::TrackLogDetail.represent ins.track_log_details.first, hide_linkable: true
    end
    expose :members, with: Entities::MemberLite, documentation: {type: Entities::MemberLite, desc: '投资人', is_array: true}
    expose :organization, with: Entities::OrganizationForSelect, documentation: {type: Entities::OrganizationForSelect, desc: '机构'}
  end
end