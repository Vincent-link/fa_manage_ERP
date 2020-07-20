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
    expose :summary_detail, documentation: {type: 'hash', desc: 'summary详细'}

    expose :org_members, using: Entities::CalendarMember
    expose :com_members, using: Entities::CalendarMember
    expose :user_members, using: Entities::CalendarMember

    expose :organization_name, documentation: {type: String, desc: '机构名称'}
    expose :organization_id, documentation: {type: Integer, desc: '机构id'}
    expose :company_id, documentation: {type: Integer, desc: '公司id'}
    expose :company_name, documentation: {type: String, desc: '公司名称'}
    expose :company_location_city_id, documentation: {type: Integer, desc: '公司city_id'}
    expose :company_location_province_id, documentation: {type: Integer, desc: '公司province_id'}
    expose :funding_id, documentation: {type: Integer, desc: '项目id'}
    expose :track_log_id, documentation: {type: Integer, desc: '关联的track_log id'}
    expose :track_log_status, documentation: {type: Integer, desc: 'track_log状态'}
    expose :track_log_members, documentation: {type: MemberLite, desc: 'track_log投资人'}

    expose :status, documentation: {type: Integer, desc: '会议状态'}
    expose :tel_desc, documentation: {type: String, desc: '电话会议描述'}

    with_options(format_with: :time_to_s_minute) do
      expose :started_at, documentation: {type: String, desc: '开始时间'}
      expose :ended_at, documentation: {type: String, desc: '结束时间'}
    end
  end
end