module Entities
  class MemberForIndex < Base
    expose :id, documentation: {type: 'integer', desc: '投资人id', required: true}
    expose :name, documentation: {type: 'string', desc: '投资人名称', required: true}
    expose :organization_id, documentation: {type: 'integer', desc: '机构id', required: true}
    expose :organization_name, documentation: {type: 'string', desc: '机构名称', required: true}
    expose :position, documentation: {type: 'string', desc: '实际职位'}
    expose :position_rank_id, documentation: {type: 'string', desc: '职级（字典member_position_rank）'}
    expose :tel, documentation: {type: 'string', desc: '电话'}
    expose :wechat, documentation: {type: 'string', desc: '微信'}
    expose :email, documentation: {type: 'string', desc: '邮箱'}
    expose :team_ids, documentation: {type: 'integer', desc: '所属团队', is_array: true}
    expose :sector_ids, documentation: {type: 'integer', desc: '关注行业', is_array: true}
    expose :currency_ids, documentation: {type: 'integer', desc: '币种', is_array: true}
    expose :round_ids, documentation: {type: 'integer', desc: '轮次', is_array: true}
    expose :any_round, documentation: {type: 'boolean', desc: '是否不限轮次'}
    expose :followed_location_ids, documentation: {type: 'integer', desc: '关注地区', is_array: true}
  end
end
