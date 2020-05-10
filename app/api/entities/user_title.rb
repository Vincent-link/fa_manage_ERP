module Entities
  class UserTitle < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: 'Title', required: true}
  end
end