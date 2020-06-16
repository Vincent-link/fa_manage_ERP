module Entities
  class FinancingEvents < Base
    expose :date, documentation: {type: 'string', desc: '更新时间', required: true}
    expose :round_id, documentation: {type: 'string', desc: '', required: true}
    expose :target_amount, documentation: {type: 'string', desc: '', required: true} do |ins|
      "#{ins.target_amount} #{ins.bi}"
    end
    expose :funding_members, documentation: {type: 'string', desc: '', required: true}
    expose :status, documentation: {type: 'string', desc: '', required: true}
  end
end
