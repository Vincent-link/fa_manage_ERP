module Entities
  class UserInvestorGroup < Base
    expose :id, documentation: {type: 'integer', desc: 'ecm组id', required: true}
    expose :name, documentation: {type: 'string', desc: '组名', required: true}
    expose :is_public, documentation: {type: 'boolean', desc: '是否公开'}
  end
end