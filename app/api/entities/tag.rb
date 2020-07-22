module Entities
  class Tag < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: '名称', required: true}
    expose :taggings_count, as: :num, documentation: {type: 'string', desc: '使用情况', required: true} do |ins|
      ins.taggings_count - 1
    end
    expose :sub_tags, using: Entities::Tag
  end
end
