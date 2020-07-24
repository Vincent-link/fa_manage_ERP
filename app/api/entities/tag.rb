module Entities
  class Tag < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: '名称', required: true}
    expose :taggings_count, as: :num, documentation: {type: 'string', desc: '使用情况', required: true} do |ins|
      {
          organization_num: organization_num(ins),
          company_num: company_num(ins),
          investor_num: investor_num(ins)
      }
    end
    expose :sub_tags, using: Entities::Tag

    private

    def organization_num(ins)
      ActsAsTaggableOn::Tagging.where(taggable_type: "Organization", tag_id: ins.id).count
    end

    def company_num(ins)
      ActsAsTaggableOn::Tagging.where(taggable_type: "Company", tag_id: ins.id).count
    end

    def investor_num(ins)
      ActsAsTaggableOn::Tagging.where(taggable_type: "Member", tag_id: ins.id).count
    end
  end
end
