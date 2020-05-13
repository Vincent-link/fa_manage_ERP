module Entities
  class Resource < Base
    expose :name, documentation: {type: 'string', desc: '权限', required: true}
    expose :desc, documentation: {type: 'string', desc: '说明', required: true}
  end
end