module Entities
  class Calendar < Base
    expose :id, documentation: {type: 'integer', desc: 'id'}
    expose :title, documentation: {type: String, desc: '标题'}
    expose :desc, documentation: {type: String, desc: '内容'}
    expose :address, using: Entities::Address, documentation: {type: Entities::Address, desc: '地址'}
    expose :address_desc, using: Entities::Address, documentation: {type: Entities::Address, desc: '地址'}
    expose :type, documentation: {type: String, desc: '日程类型'}
    expose :meeting_type, documentation: {type: String, desc: '约见方式'}
    expose :meeting_type_desc, documentation: {type: String, desc: '约见方式描述'}
    expose :meeting_category, documentation: {type: String, desc: '会议类别'}
    expose :meeting_category_desc, documentation: {type: String, desc: '会议类别描述'}
    expose :summary, documentation: {type: 'boolean', desc: '会议纪要'}
    expose :track_log_id, documentation: {type: Integer, desc: '关联的track_log id'}
    expose :summary_detail, documentation: {type: 'hash', desc: 'summary详细'}

    expose :calendar_members

    with_options(format_with: :time_to_s_minute) do
      expose :started_at, documentation: {type: String, desc: '开始时间'}
      expose :ended_at, documentation: {type: String, desc: '结束时间'}
    end
  end
end