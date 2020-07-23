module Entities
  class TagCategory < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: '名称', required: true}
    expose :coverage, documentation: {type: 'string', desc: '适用范围', required: true}
    expose :tags, documentation: {type: 'string', desc: '标签', required: true}
  end
end
