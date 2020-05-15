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
    expose :logo, using: Entities::File,if: ->(ins) {ins.logo.present?}, documentation: {type: Entities::File, desc: '机构logo'}

    expose :sector_ids, documentation: {type: 'integer', desc: '行业', is_array: true}
    expose :round_ids, documentation: {type: 'integer', desc: '轮次', is_array: true}
    expose :currency_ids, documentation: {type: 'integer', desc: '币种', is_array: true}
    expose :tag_ids, documentation: {type: 'integer', desc: '标签', is_array: true}
    expose :tag_desc, documentation: {type: String, desc: '标签', is_array: true} do |ins|
      ['阿斯顿发斯蒂芬', '阿蒂芬']
    end #todo 假数据
    expose :any_round, documentation: {type: 'boolean', desc: '不限轮次'}

    expose :teams, documentation: {type: 'string', desc: '机构团队', is_array: true}
    expose :addresses, using: Entities::Address, documentation: {type: 'Entities::Address', desc: '机构团队', is_array: true}

    expose :invest_period, documentation: {type: 'integer', desc: '投资周期'}
    expose :decision_flow, documentation: {type: 'string', desc: '投资决策流程'}
    expose :ic_rule, documentation: {type: 'string', desc: '投委会机制'}
    expose :alias, documentation: {type: 'string', desc: '机构别名', is_array: true}

    with_options(format_with: :time_to_s_second) do
      expose :updated_at_of_collect_info, documentation: {type: Time, desc: '募资情况更新时间'}
      expose :updated_at_of_stock_info, documentation: {type: Time, desc: '剩余可投更新时间'}
      expose :updated_at_of_rmb_amount, documentation: {type: Time, desc: 'rmb单笔投资金额更新时间'}
      expose :updated_at_of_usd_amount, documentation: {type: Time, desc: 'usd单笔投资金额更新时间'}
    end

    expose :lead_organizations, using: Entities::OrganizationForSelect, documentation: {type: Entities::OrganizationForSelect, desc: '上级机构'}
    expose :mate_organizations, using: Entities::OrganizationForSelect, documentation: {type: Entities::OrganizationForSelect, desc: '同级机构'}

    expose :last_ir_review, using: Entities::Comment, documentation: {type: Entities::Comment, desc: '最新ir'}
    expose :last_newsfeed, using: Entities::Comment, documentation: {type: Entities::Comment, desc: '最新newsfeed'}
  end
end