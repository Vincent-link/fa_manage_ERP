module Entities
  class FinancingEvents < Base
    expose :id, documentation: {type: 'integer', desc: '投资事件id', required: true}
    with_options(format_with: :time_to_s_date) do
      expose :date, documentation: {type: 'string', desc: '更新时间', required: true}
    end
    expose :round_id, documentation: {type: 'string', desc: '投资轮次id', required: true}
    expose :target_amount, documentation: {type: 'string', desc: '融资额', required: true}
    expose :funding_members, documentation: {type: 'string', desc: '项目成员', required: true}
    expose :status, documentation: {type: 'string', desc: '状态', required: true}
  end
end
