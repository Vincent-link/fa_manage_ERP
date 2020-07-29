module Entities
  class QuestionnaireBatchFundingWithEvaluation < Base
    expose :eva_batch_id, documentation: {type: 'integer', desc: '批次id'}

    with_options(format_with: :time_to_s_date) do
      expose :eva_batch_start_at, documentation: {type: 'string', desc: '互评开始日期'}
      expose :funding_excution_date, documentation: {type: 'string', desc: '项目启动日期'}
    end
    expose :eva_batch_name, documentation: {type: 'string', desc: '互评批次'}
    expose :batch_funding_status, documentation: {type: 'integer', desc: '互评状态'}
    expose :batch_funding_status_desc, documentation: {type: 'string', desc: '互评状态中文'}
    expose :funding_id, documentation: {type: 'integer', desc: '项目id'}
    expose :funding_name, documentation: {type: 'string', desc: '项目名称'}
    expose :commit_count, documentation: {type: 'integer', desc: '提交人数'}
    expose :should_commit_count, documentation: {type: 'integer', desc: '应该提交的人数'}
    expose :evaluation_list, documentation: {type: 'hash', desc: '提交情况'}
  end
end