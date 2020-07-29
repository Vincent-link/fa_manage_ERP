module Entities
  class QuestionnaireEvaluation < Base
    expose :eva_batch_id, documentation: {type: 'integer', desc: '批次id'}
    expose :appraisee, documentation: {type: 'integer', desc: '被评估人id'}

    with_options(format_with: :time_to_s_date) do
      expose :eva_batch_start_at, documentation: {type: 'string', desc: '互评开始日期'}
      expose :submitted_at, documentation: {type: 'string', desc: '提交时间'}
    end
    expose :eva_batch_name, documentation: {type: 'string', desc: '互评批次'}
    expose :batch_funding_status, documentation: {type: 'integer', desc: '互评状态'}
    expose :batch_funding_status_desc, documentation: {type: 'string', desc: '互评状态中文'}
    expose :funding_id, documentation: {type: 'integer', desc: '项目id'}
    expose :funding_name, documentation: {type: 'string', desc: '项目名称'}
    expose :appraisee_name, documentation: {type: 'string', desc: '被评估人名称'}
    expose :commit_status, documentation: {type: 'boolean', desc: '提交状态'}
    expose :evaluation_id, documentation: {type: 'integer', desc: '互评id'}
  end
end