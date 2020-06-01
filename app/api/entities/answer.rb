module Entities
  class Answer < Grape::Entity
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :desc, documentation: {type: 'string', desc: '描述', required: true}
    expose :user, using: Entities::User
    expose :question_id, documentation: {type: 'integer', desc: '问题id', required: true}
  end
end
