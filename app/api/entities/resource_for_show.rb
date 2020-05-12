module Entities
  class ResourceForShow < Base
    expose :name, documentation: {type: 'string', desc: '权限组', required: true}
    expose :desc, documentation: {type: 'string', desc: '说明', required: true}
  end
end