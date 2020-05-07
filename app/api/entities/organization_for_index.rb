module Entities
  class OrganizationForIndex < Base
    expose :id, documentation: {type: 'integer', desc: '机构id', required: true}
    expose :name, documentation: {type: 'string', desc: '机构名称', required: true}
    expose :level, documentation: {type: 'string', desc: '机构级别'}

    expose :last_investevent, using: InvesteventLite, documentation: {type: 'InvestmentEvent', desc: '最后融资'}

    expose :sector_ids, documentation: {type: 'integer', desc: '行业', is_array: true}
    expose :round_ids, documentation: {type: 'integer', desc: '轮次', is_array: true}
    expose :currency_ids, documentation: {type: 'integer', desc: '币种', is_array: true}

    expose :better_search_highlights, documentation: {type: 'hash', desc: 'es结果高亮'}
  end
end