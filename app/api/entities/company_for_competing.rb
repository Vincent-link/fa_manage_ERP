module Entities
  class CompanyForCompeting < Base
    expose :id, documentation: {type: 'integer', desc: '竞争公司id'}
    expose :name, documentation: {type: 'integer', desc: '名称'}
    expose :parent_sector_id, documentation: {type: 'integer', desc: '行业'}
    expose :recent_financing, documentation: {type: 'integer', desc: '最近融资'}
    expose :location_province_id, documentation: {type: 'integer', desc: '地点'}
    with_options(format_with: :time_to_s_second) do
      expose :created_at, documentation: {type: 'string', desc: '成立时间'}
    end
  end
end
