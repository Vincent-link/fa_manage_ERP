module Entities
  class TrackLogDetailLite < Base
    expose :id, documentation: {type: 'integer', desc: '跟进记录 id'}
    expose :content, documentation: {type: 'string', desc: '跟进记录'}
    with_options(format_with: :time_to_s_date) do
      expose :updated_at, documentation: {type: 'date', desc: '更新时间'}
    end
  end
end