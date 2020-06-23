module Entities
  class KnowledgeBase < Grape::Entity
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :name, documentation: {type: 'string', desc: '描述', required: true}
    expose :children, using: Entities::KnowledgeBase
  end
end
