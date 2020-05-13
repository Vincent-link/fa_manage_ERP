module Entities
  class EcmGroupForShow < Base
    expose :id, documentation: {type: 'integer', desc: 'group_id', required: true}
    expose :name, documentation: {type: 'string', desc: 'group名称', required: true}
    expose :investor_group_organizations, using: Entities::EcmGroupOrganization
  end
end