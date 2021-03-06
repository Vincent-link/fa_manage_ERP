module Entities
  class Team < Base
    expose :id, documentation: {type: 'integer', desc: '团队id', required: true}
    expose :name, documentation: {type: 'string', desc: '团队名称', required: true}
    expose :users, using: Entities::User
  end
end
