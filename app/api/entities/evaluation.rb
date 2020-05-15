module Entities
  class Evaluation < Base
    expose :id, documentation: {type: 'integer', desc: 'id', required: true}
    expose :market, documentation: {type: 'string', desc: '市场', required: true}
    expose :business, documentation: {type: 'string', desc: '业务', required: true}
    expose :team, documentation: {type: 'integer', desc: '团队', required: true}

    expose :exchange, documentation: {type: 'string', desc: '交易', required: true}
    expose :is_agree, documentation: {type: 'string', desc: '是否通会', required: true}
    expose :other, documentation: {type: 'integer', desc: '其他建议', required: true}
    expose :name, documentation: {type: 'integer', desc: '用户名称', required: true}

    expose :avatar, documentation: {type: 'integer', desc: '用户头像', required: true}
    expose :created_at, documentation: {type: 'integer', desc: '用户评分时间', required: true}
  end
end
