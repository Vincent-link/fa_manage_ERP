module Entities
  class Question < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :desc, documentation: {type: 'integer', desc: '描述', required: true}
    expose :evaluation, using: Entities::Evaluation
    expose :answer, using: Entities::Answer do |question, options|
      question.answers
    end
    expose :created_at, documentation: {type: 'integer', desc: '提交问题时间', required: true}
  end
end
