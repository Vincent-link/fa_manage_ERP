module Entities
  class DmMemberLite < Base
    expose :id, documentation: {type: 'integer', desc: '投资人id', required: true}
    expose :name, documentation: {type: 'string', desc: '投资人名称', required: true}
    expose :fa_member, documentation: {type: 'boolean', desc: '是否是FA成员', required: true} do |dm_org, options|
      options[:member_hash].has_key? dm_org.id
    end
  end
end