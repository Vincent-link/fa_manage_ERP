module Entities
  class Roles < Base
    expose :id, documentation: {type: 'integer', desc: '权限组id', required: true}
    expose :name, documentation: {type: 'string', desc: '权限组', required: true}
  end
end