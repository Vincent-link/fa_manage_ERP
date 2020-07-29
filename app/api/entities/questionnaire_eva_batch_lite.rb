module Entities
  class QuestionnaireEvaBatchLite < Base
    expose :id, documentation: {type: 'integer', desc: '批次id'}
    expose :batch_name, documentation: {type: 'string', desc: '轮次名字'}
  end
end