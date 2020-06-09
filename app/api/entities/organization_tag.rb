module Entities
  class OrganizationTag < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: '名称', required: true}
    expose :taggings_count, as: :organization_num, documentation: {type: 'string', desc: '机构数量', required: true} do |ins|
       ActsAsTaggableOn::Tagging.where(tag_id: ins.id, taggable_type: "Company").count
      # ins.taggings_count - 1
    end
  end
end
