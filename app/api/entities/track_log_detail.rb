module Entities
  class TrackLogDetail < Base
    expose :id, documentation: {type: 'integer', desc: '跟进记录 id'}
    expose :content, documentation: {type: 'string', desc: '跟进记录'}
    expose :detail_type, documentation: {type: 'integer', desc: '跟进记录信息类型'}
    with_options(format_with: :time_to_s_date) do
      expose :created_at, documentation: {type: 'date', desc: '创建时间'}
    end
  end
end