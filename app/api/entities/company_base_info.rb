module Entities
  class CompanyBaseInfo < Base
    expose :id, documentation: {type: 'integer', desc: '公司id'}
    expose :name, documentation: {type: 'string', desc: '公司名称'}
    expose :logo, using: Entities::File,if: ->(ins) {ins.logo.present?}, documentation: {type: Entities::File, desc: 'logo'}
    expose :website, documentation: {type: 'string', desc: '公司网址'}
    expose :one_sentence_intro, documentation: {type: 'string', desc: '一句话简介'}
    expose :detailed_intro, documentation: {type: 'string', desc: '详细介绍'}
    expose :location_province_id, documentation: {type: 'integer', desc: '省份'}
    expose :location_city_id, documentation: {type: 'integer', desc: '城市'}
    expose :detailed_address, documentation: {type: 'string', desc: '详细地址'}
    expose :sectors, documentation: {type: 'string', desc: '所属行业'}
    expose :company_tags, documentation: {type: 'string', desc: '标签'}
    expose :financing_events, using: Entities::FinancingEvents
    expose :is_ka, documentation: {type: 'boolean', desc: '是否ka'}
    with_options(format_with: :time_to_s_second) do
      expose :updated_at, documentation: {type: 'datetime', desc: '最近更新时间'}
    end
    # expose :address, with: Entities::Address, documentation: {type: 'string', desc: '地址'}
  end
end
