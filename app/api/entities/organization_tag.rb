module Entities
  class OrganizationTag < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: '名称', required: true}
    expose :taggings_count, as: :num, documentation: {type: 'string', desc: '机构数量', required: true} do |ins|
      ins.taggings_count - 1
    end
    expose :sub_tags, using: Entities::OrganizationTag
  end
end
