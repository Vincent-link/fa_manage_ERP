module Entities
  class UserTitle < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: 'Title', required: true}
    expose :users, documentation: {type: 'string', desc: 'Title对应用户', required: true, is_array: true}
  end
end