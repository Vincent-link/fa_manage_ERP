module Entities
  class Role < Base
    expose :id, documentation: {type: 'integer', desc: '权限组id', required: true}
    expose :name, documentation: {type: 'string', desc: '权限组', required: true}
    expose :desc, documentation: {type: 'string', desc: '说明', required: true}
  end
end