module Entities
  class Resource < Base
    expose :name, as: :id, documentation: {type: 'string', desc: '权限', required: true}
    expose :desc, as: :name, documentation: {type: 'string', desc: '说明', required: true}
  end
end