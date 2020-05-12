module Entities
  class RoleResource < Base
    expose :name, documentation: {type: 'string', desc: '权限', required: true}
  end
end