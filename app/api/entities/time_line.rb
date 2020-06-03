module Entities
  class TimeLine < Base
    expose :id, documentation: {type: 'integer', desc: 'TimeLine id'}
    expose :status_type, documentation: {type: 'string', desc: '状态'} do |ins|
      'Funding'.constantize.status_desc_for_value(ins.status)
    end
    with_options(format_with: :time_to_s_date) do
      expose :created_at, documentation: {type: 'date', desc: '状态对应日期'}
    end
  end
end