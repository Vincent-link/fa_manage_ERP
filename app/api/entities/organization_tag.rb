module Entities
  class OrganizationTag < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: '名称', required: true}
    expose :organization_num, documentation: {type: 'string', desc: '机构数量', required: true}
  end
end