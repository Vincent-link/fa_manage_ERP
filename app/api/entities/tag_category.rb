module Entities
  class TagCategory < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: '名称', required: true}
    expose :coverage, documentation: {type: 'array[string]', desc: '适用范围', required: true}
    expose :tags, using: Entities::TagLite
  end
end
