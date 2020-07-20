module Entities
  class TrackLogDetail < Base
    expose :id, documentation: {type: 'integer', desc: '跟进记录 id'}
    expose :content, documentation: {type: 'string', desc: '跟进记录'}
    expose :user, with: Entities::User, documentation: {type: Entities::User, desc: '用户'}
    expose :detail_type, documentation: {type: 'integer', desc: '跟进记录信息类型'}
    with_options(format_with: :time_to_s_date) do
      expose :created_at, documentation: {type: 'date', desc: '创建时间'}
    end
    expose :linkable_id, documentation: {type: 'integer', desc: '约见id'}
    expose :linkable_type, documentation: {type: 'string', desc: '类型目前只有约见'}
    expose :track_log_status, documentation: {type: 'integer', desc: '变更后的状态'} do |ins|
      ins.history[:status]
    end
    expose :history, as: :spa_history, if: lambda { |ins| ins.detail_type_spa?}, documentation: {type: Entities::TrackLogDetailHistorySpa, desc: 'SPA类型的历史记录'}
    expose :history, as: :ts_history, if: lambda { |ins| ins.detail_type_ts?}, documentation: {type: Entities::TrackLogDetailHistoryTs, desc: 'TS类型的历史记录'}
    expose :history, as: :calendar_history, if: lambda { |ins| ins.detail_type_calendar?}, documentation: {type: Entities::TrackLogDetailHistoryCalendar, desc: '约见类型的历史记录'}
  end
end