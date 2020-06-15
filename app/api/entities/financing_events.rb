module Entities
  class FinancingEvents < Base
    with_options(format_with: :time_to_s_second) do
      expose :date, documentation: {type: 'string', desc: '更新时间', required: true}
    end
    expose :round_id, documentation: {type: 'string', desc: '', required: true}
    expose :target_amount, documentation: {type: 'string', desc: '', required: true}
    expose :funding_members, documentation: {type: 'string', desc: '', required: true}
    expose :status, documentation: {type: 'string', desc: '', required: true}
  end
end
