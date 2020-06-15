module Entities
  class TrackLogDetailHistoryCalendar < Base
    expose :id, documentation: {type: 'integer', desc: '会议id'}
    expose :status, documentation: {type: 'integer', desc: '状态id'}
    expose :status_desc, documentation: {type: 'string', desc: '状态'}
    expose :address_id, documentation: {type: 'integer', desc: '地址id'}
    expose :address_desc, documentation: {type: 'string', desc: '地址'}
    with_options(format_with: :time_to_s_minute) do
      expose :started_at, documentation: {type: String, desc: '开始时间'}
      expose :ended_at, documentation: {type: String, desc: '结束时间'}
    end
    expose :meeting_type, documentation: {type: String, desc: '约见方式'}
    expose :meeting_type_desc, documentation: {type: String, desc: '约见方式描述'}
  end
end