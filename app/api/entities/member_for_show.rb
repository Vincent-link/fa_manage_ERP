module Entities
  class MemberForShow < Base
    expose :id, documentation: {type: 'integer', desc: '投资人id', required: true}
    expose :name, documentation: {type: 'string', desc: '投资人名称', required: true}
    expose :organization_name, documentation: {type: 'string', desc: '机构名称', required: true}
    expose :tel, documentation: {type: 'string', desc: '电话'}
    expose :wechat, documentation: {type: 'string', desc: '微信'}
    expose :email, documentation: {type: 'string', desc: '邮箱'}
    expose :team_ids, documentation: {type: 'integer', desc: '所属团队', is_array: true}
    expose :card_attachment, as: :card, using: Entities::File, documentation: {type: Entities::File, desc: '名片', required: true}
    expose :avatar_attachment, as: :avatar, using: Entities::File, documentation: {type: Entities::File, desc: '用户头像', required: true}
    expose :position, documentation: {type: 'string', desc: '实际职位'}
    expose :position_rank_id, documentation: {type: 'integer', desc: '职级'}
    expose :address, using: Entities::Address, documentation: {type: 'Entities::Address', desc: '办公地点'}

    expose :sector_ids, documentation: {type: 'integer', desc: '关注行业', is_array: true}
    expose :round_ids, documentation: {type: 'integer', desc: '关注轮次', is_array: true}
    expose :currency_ids, documentation: {type: 'integer', desc: '关注币种', is_array: true}
    expose :scale_ids, documentation: {type: 'integer', desc: '关注投资规模', is_array: true}
    expose :tag_ids, documentation: {type: 'integer', desc: '标签', is_array: true}
    expose :tag_desc, documentation: {type: String, desc: '标签', is_array: true} do |ins|
      ['阿斯顿发斯蒂芬', '阿蒂芬']
    end #todo 假数据
    expose :followed_location_ids, documentation: {type: 'integer', desc: '关注地区', is_array: true}

    expose :users, as: :covered_by, using: Entities::UserForShow, documentation: {type: 'Entities::UserLite', desc: '对接成员'}

    expose :sponsor, using: Entities::UserLite, documentation: {type: 'Entities::UserLite', desc: '来源'}
    expose :is_head, documentation: {type: 'boolean', desc: '是否高层'}
    expose :is_ic, documentation: {type: 'boolean', desc: '是否投委会'}
    expose :is_president, documentation: {type: 'boolean', desc: '是否最高决策人'}
    expose :report_relations, as: :report_lines, using: Entities::DmMemberReportRelation, documentation: {type: Entities::DmMemberReportRelation, desc: '汇报关系'}
    expose :solid_report_lower, using: Entities::MemberLite, documentation: {type: 'integer', desc: '实线下级', is_array: true}
    expose :virtual_report_lower, using: Entities::MemberLite, documentation: {type: 'integer', desc: '虚线下级', is_array: true}

    expose :ir_review, documentation: {type: 'string', desc: 'IrReview'}
    expose :intro, documentation: {type: 'string', desc: '简介'}
    expose :is_dimission, documentation: {type: 'boolean', desc: '是否已离职'}
  end
end