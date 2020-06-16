module Entities
  class TeamLite < Base
    expose :id, documentation: {type: 'integer', desc: '团队id', required: true}
    expose :name, documentation: {type: 'string', desc: '团队名称', required: true}
  end
end
