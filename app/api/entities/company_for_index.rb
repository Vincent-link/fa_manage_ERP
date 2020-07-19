module Entities
  class CompanyForIndex < Base
    expose :id, documentation: {type: 'integer', desc: '公司id'}
    expose :name, documentation: {type: 'string', desc: '公司名称'}
    expose :sector_id, documentation: {type: 'string', desc: '行业'}
    expose :location_province_id, documentation: {type: 'integer', desc: '省份'}
    expose :recent_financing, documentation: {type: 'string', desc: '最近融资'}
    expose :callreport_num, documentation: {type: 'string', desc: 'callreport数量'} do |ins|
      '假数据'
    end
    expose :is_ka, documentation: {type: 'boolean', desc: '是否ka'}
    with_options(format_with: :time_to_s_second) do
      expose :updated_at, documentation: {type: 'datetime', desc: '最近更新时间'}
    end
    expose :financing_events, documentation: {type: 'string', desc: '融资事件'} do |ins, options|
      ins.financing_events("not_kun")
    end
    expose :one_sentence_intro, documentation: {type: 'string', desc: '一句话简介'}
  end
end
