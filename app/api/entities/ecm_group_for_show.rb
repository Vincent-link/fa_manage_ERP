module Entities
  class EcmGroupForShow < Base
    expose :id, documentation: {type: 'integer', desc: 'group_id', required: true}
    expose :name, documentation: {type: 'string', desc: 'group名称', required: true}
    expose :sector_ids, documentation: {type: 'integer', desc: '关注行业', is_array: true}
    expose :investor_group_organizations, using: Entities::EcmGroupOrganization
  end
end