module Entities
  class PipelineDivide < Base
    expose :id, documentation: {type: 'integer', desc: 'id'}
    expose :pipeline_id, documentation: {type: 'integer'}
    expose :user_id, documentation: {type: 'integer', desc: '分成人id'}
    expose :bu_id, documentation: {type: 'integer', desc: '分成buid'}
    expose :team_id, documentation: {type: 'integer', desc: '分成团队id'}
    expose :rate, documentation: {type: 'integer', desc: '分成比例'}

    with_options(format_with: :time_to_s_second) do
      expose :updated_at, documentation: {type: 'time', desc: '更新时间'}
    end
  end
end