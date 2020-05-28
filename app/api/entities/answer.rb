module Entities
  class Answer < Grape::Entity
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :desc, documentation: {type: 'string', desc: 'id', required: true}
    expose :user, using: Entities::User
    expose :question_id, documentation: {type: 'integer', desc: 'id', required: true}
  end
end
