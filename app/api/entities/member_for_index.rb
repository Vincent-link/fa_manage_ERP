module Entities
  class MemberForIndex < Base
    expose :id, documentation: {type: 'integer', desc: '投资人id', required: true}
    expose :name, documentation: {type: 'string', desc: '投资人名称', required: true}
    expose :organization_name, documentation: {type: 'string', desc: '机构名称', required: true}
    expose :position, documentation: {type: 'string', desc: '实际职位'}
    expose :tel, documentation: {type: 'string', desc: '电话'}
    expose :wechat, documentation: {type: 'string', desc: '微信'}
    expose :email, documentation: {type: 'string', desc: '邮箱'}
    expose :team, documentation: {type: 'string', desc: '所属团队'}
    expose :sector_ids, documentation: {type: 'integer', desc: '关注行业', is_array: true}
  end
end