module Entities
  class MemberResume < Base
    expose :id, documentation: {type: 'integer', desc: 'id'}
    expose :organization_id, documentation: {type: 'integer', desc: '机构id'}
    expose :organization_name, documentation: {type: 'string', desc: '机构名称'}
    expose :title, documentation: {type: 'string', desc: '职位'}
    expose :member_id, documentation: {type: 'integer', desc: '投资人id'}
    expose :started_date, documentation: {type: 'date', desc: '开始时间'}
    expose :closed_date, documentation: {type: 'date', desc: '结束时间'}

    with_options(format_with: :time_to_s_second) do
      expose :created_at, documentation: {type: 'time', desc: '创建时间'}
      expose :updated_at, documentation: {type: 'time', desc: '更新时间'}
    end
  end
end