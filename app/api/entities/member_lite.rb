module Entities
  class MemberLite < Base
    expose :id, documentation: {type: 'integer', desc: '投资人id', required: true}
    expose :name, documentation: {type: 'string', desc: '投资人名称', required: true}
    expose :position, documentation: {type: 'string', desc: '实际职位'}
  end
end