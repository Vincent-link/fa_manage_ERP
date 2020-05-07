module Entities
  class OrganizationForShow < Base
    expose :id, documentation: {type: 'integer', desc: '机构id', required: true}
    expose :name, documentation: {type: 'string', desc: '机构名称', required: true}
    expose :en_name, documentation: {type: 'string', desc: '机构英文名'}
    expose :level, documentation: {type: 'string', desc: '机构级别'}
    expose :site, documentation: {type: 'string', desc: '机构网址'}
    expose :aum, documentation: {type: 'string', desc: '资产管理规模'}
    expose :collect_info, documentation: {type: 'string', desc: '募资情况'}
    expose :stock_info, documentation: {type: 'string', desc: '剩余可投规模'}
    expose :rmb_amount_min, documentation: {type: 'string', desc: '人民币可投下限'}
    expose :rmb_amount_max, documentation: {type: 'string', desc: '人民币可投上限'}
    expose :usd_amount_min, documentation: {type: 'string', desc: '美元可投下限'}
    expose :usd_amount_max, documentation: {type: 'string', desc: '美元可投上限'}

    expose :followed_location_ids, documentation: {type: 'integer', desc: '关注地区', is_array: true}
    expose :intro, documentation: {type: 'string', desc: '机构介绍'}
    expose :logo, documentation: {type: 'string', desc: '机构logo'}

    expose :sector_ids, documentation: {type: 'integer', desc: '行业', is_array: true}
    expose :round_ids, documentation: {type: 'integer', desc: '轮次', is_array: true}
    expose :currency_ids, documentation: {type: 'integer', desc: '币种', is_array: true}
    expose :tag_ids, documentation: {type: 'integer', desc: '标签', is_array: true}

    expose :teams, documentation: {type: 'string', desc: '机构团队', is_array: true}
    expose :addresses, using: Entities::Address, documentation: {type: 'Entities::Address', desc: '机构团队', is_array: true}
  end
end