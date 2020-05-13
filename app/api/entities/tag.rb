module Entities
  class Tag < Base
    expose :id, documentation: {type: 'integer', desc: 'tag id'}
    expose :name, documentation: {type: String, desc: 'tag名称'}
  end
end