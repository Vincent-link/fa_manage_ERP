module Entities
  class EcmGroupOrganization < Base
    expose :id, documentation: {type: 'integer', desc: '条目id', required: true}
    expose :name, documentation: {type: 'string', desc: '机构名称', required: true}
    expose :organization_id, documentation: {type: Integer, desc: '机构id', required: true}
    expose :tier, documentation: {type: Integer, desc: 'tier', required: true}
    expose :members, using: Entities::MemberLite
  end
end