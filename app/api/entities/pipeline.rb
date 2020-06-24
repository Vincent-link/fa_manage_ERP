module Entities
  class Pipeline < Base
    expose :id, documentation: {type: 'integer', desc: 'id'}

    expose :funding_id, documentation: {type: 'integer', desc: '项目id'}
    expose :funding_status_desc, documentation: {type: 'string', desc: '项目状态'}
    expose :status, documentation: {type: 'integer', desc: '所处阶段'}
    expose :est_amount, documentation: {type: 'integer', desc: '预期融资金额'}
    expose :est_amount_currency, documentation: {type: 'integer', desc: '预期融资金额币种'}
    expose :fee_rate, documentation: {type: 'integer', desc: '费率'}
    expose :fee_discount, documentation: {type: 'integer', desc: '费率折扣'}
    expose :other_amount, documentation: {type: 'integer', desc: '其他金额'}
    expose :complete_rate, documentation: {type: 'integer', desc: '年内完成概率'}
    expose :total_fee, documentation: {type: 'integer', desc: '项目总收入预测'}
    expose :total_fee_currency, documentation: {type: 'integer', desc: '项目总收入币种'}
    expose :currency_rate, documentation: {type: 'integer', desc: '汇率'}
    expose :el_date, documentation: {type: 'date', desc: '签约日期'}
    expose :est_bill_date, documentation: {type: 'date', desc: '预计账单日期'}

    expose :pipeline_divides, using: Entities::PipelineDivide, documentation: {type: Entities::PipelineDivide, desc: '分成'}
    expose :payments, using: Entities::Payment, documentation: {type: Entities::Payment, desc: '账单'}

    with_options(format_with: :time_to_s_second) do
      expose :updated_at, documentation: {type: 'time', desc: '更新时间'}
    end
  end
end