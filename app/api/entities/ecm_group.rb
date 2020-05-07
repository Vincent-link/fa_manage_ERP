module Entities
  class EcmGroup < Base
    expose :id, documentation: {type: 'integer', desc: 'ecm组id', required: true}
    expose :name, documentation: {type: 'string', desc: '组名', required: true}
    expose :sectors, documentation: {type: 'integer', desc: '关注行业', is_array: true}
  end
end