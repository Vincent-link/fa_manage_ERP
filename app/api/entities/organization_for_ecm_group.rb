module Entities
  class OrganizationForEcmGroup < Base
    expose :id, documentation: {type: 'integer', desc: '机构id', required: true}
    expose :name, documentation: {type: 'string', desc: '机构名称', required: true}
    expose :level, documentation: {type: 'string', desc: '机构级别'}

    expose :last_investevent, using: InvesteventLite, documentation: {type: 'InvestmentEvent', desc: '最后融资'}

    expose :sector_ids, documentation: {type: 'integer', desc: '行业', is_array: true}
    expose :round_ids, documentation: {type: 'integer', desc: '轮次', is_array: true}
    expose :currency_ids, documentation: {type: 'integer', desc: '币种', is_array: true}
    expose :any_round, documentation: {type: 'boolean', desc: '是否不限轮次', is_array: true}

    expose :last_ir_review, documentation: {type: Entities::Comment, desc: '最新ir'}
    expose :last_newsfeed, documentation: {type: Entities::Comment, desc: '最新newsfeed'}


    expose :t_search_highlights, as: :search_highlights, documentation: {type: 'hash', desc: 'es结果高亮'}
    expose :tier do |ins, option|
      option[:ecm_group].investor_group_organizations.where(organization_id: ins.id).first&.tier
    end

    expose :members do |ins, option|
      Entities::MemberLite.represent option[:ecm_group].investor_group_organizations.where(organization_id: ins.id).first&.members
    end

    expose :covered_users do |ins, option|
      Entities::UserLite.represent option[:ecm_group].investor_group_organizations.where(organization_id: ins.id).first&.covered_users
    end
  end
end