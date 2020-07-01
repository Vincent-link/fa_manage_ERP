module Entities
  class TagCategory < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: '名称', required: true}
    expose :tag_category_type, documentation: {type: 'string', desc: '类型', required: true}
  end
end
