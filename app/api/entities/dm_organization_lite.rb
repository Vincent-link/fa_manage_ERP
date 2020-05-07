module Entities
  class DmOrganizationLite < Base
    expose :id, documentation: {type: 'integer', desc: '机构id', required: true}
    expose :name, documentation: {type: 'string', desc: '机构名称', required: true}
    expose :fa_org, documentation: {type: 'boolean', desc: '是否是FA机构', required: true} do |dm_org, options|
      options[:org_hash].has_key? dm_org.id
    end
  end
end