module Entities
  class CompanyBaseInfo < Base
    expose :id, documentation: {type: 'integer', desc: '公司id'}
    expose :name, documentation: {type: 'string', desc: '公司名称'}
    expose :logo, using: Entities::File,if: ->(ins) {ins.logo.present?}, documentation: {type: Entities::File, desc: 'logo'}
    expose :one_sentence_intro, documentation: {type: 'string', desc: '一句话简介'}
    expose :location_province_id, documentation: {type: 'integer', desc: '省份'}
    expose :location_city_id, documentation: {type: 'integer', desc: '城市'}
    expose :detailed_address, documentation: {type: 'string', desc: '详细地址'}
    expose :sectors, documentation: {type: 'string', desc: '所属行业'}
    expose :is_ka, documentation: {type: 'boolean', desc: '是否ka'}
  end
end
