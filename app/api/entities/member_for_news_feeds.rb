module Entities
  class MemberForNewsFeeds < Base
    expose :id, documentation: {type: 'integer', desc: '投资人id'}
    expose :name, documentation: {type: 'string', desc: '投资人名称'}
    expose :avatar, documentation: {type: 'string', desc: '投资人头像url'} do |ins|
      ins.avatar_attachment&.service_url
    end
    expose :organization_id, documentation: {type: 'integer', desc: '机构id', required: true}
    expose :organization_name, documentation: {type: 'string', desc: '机构名称', required: true}
    expose :organization_logo, documentation: {type: 'string', desc: '机构logo url'} do |ins|
      ins.organization&.logo_attachment&.service_url
    end

    with_options(if: {type: PaperTrail::Version.news_feeds_type_value("member_change_org")}) do
      expose :previous_organization_id, documentation: {type: 'integer', desc: '更改前机构id'} do |_ins, opt|
        opt[:changes]["organization_id"].first
      end
      expose :previous_organization_name, documentation: {type: 'string', desc: '更改前机构名称'} do |_ins, opt|
        Organization.find_by_id(opt[:changes]["organization_id"].first)&.name
      end
      expose :following_organization_id, documentation: {type: 'integer', desc: '更改后机构id'} do |_ins, opt|
        opt[:changes]["organization_id"].last
      end
      expose :following_organization_name, documentation: {type: 'string', desc: '更改后机构名称'} do |_ins, opt|
        Organization.find_by_id(opt[:changes]["organization_id"].last)&.name
      end
    end

    expose :position_rank_id, as: :position, documentation: {type: 'integer', desc: '职级'}

    with_options(if: {type: PaperTrail::Version.news_feeds_type_value("member_change_position")}) do
      expose :previous_position, documentation: {type: 'integer', desc: '更改前职级'} do |_ins, opt|
        opt[:changes]["position_rank_id"].first
      end
      expose :following_position, documentation: {type: 'integer', desc: '更改后职级'} do |_ins, opt|
        opt[:changes]["position_rank_id"].last
      end
    end

    expose :round_ids, documentation: {type: 'integer', desc: '关注轮次', is_array: true}
    expose :sector_ids, documentation: {type: 'integer', desc: '关注行业', is_array: true}
  end
end
