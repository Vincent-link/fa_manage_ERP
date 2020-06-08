module Entities
  class MemberForCard < Base
    expose :id, documentation: {type: 'integer', desc: '投资人id', required: true}
    expose :name, documentation: {type: 'string', desc: '投资人名称', required: true}
    expose :avatar_attachment, as: :avatar, using: Entities::File, documentation: {type: Entities::File, desc: '头像url', required: true}
    expose :organization_name, documentation: {type: 'string', desc: '机构name', required: true}
  end
end