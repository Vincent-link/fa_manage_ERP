module Entities
  class IdName < Base
    expose :id, documentation: {type: 'integer', desc: 'id'}
    expose :name, documentation: {type: 'string', desc: 'name'}
  end
end