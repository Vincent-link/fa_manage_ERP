module Entities
  class MemberForNewsFeeds < Base
    expose :id, documentation: {type: 'integer', desc: '投资人id'} do |ins|
      ins.item&.id
    end
    expose :name, documentation: {type: 'string', desc: '投资人名称'} do |ins|
      ins.present_data("name")
    end
    expose :avatar, documentation: {type: 'string', desc: '投资人头像url'} do |ins|
      ins.item&.avatar_attachment&.service_url
    end
    expose :organization_id, documentation: {type: 'integer', desc: '机构id'} do |ins|
      ins.present_data("organization_id")
    end
    expose :organization_name, documentation: {type: 'string', desc: '机构名称'}do |_ins, opt|
      opt[:previous_org]&.name
    end
    expose :organization_logo, documentation: {type: 'string', desc: '机构logo url'} do |_ins, opt|
      opt[:previous_org]&.logo_attachment&.service_url
    end

    with_options(if: {type: PaperTrail::Version.news_feeds_type_value("member_change_org")}) do
      expose :previous_organization_id, documentation: {type: 'integer', desc: '更改前机构id'} do |ins|
        ins.present_data("organization_id")
      end
      expose :previous_organization_name, documentation: {type: 'string', desc: '更改前机构名称'} do |_ins, opt|
        opt[:previous_org]&.name
      end
      expose :following_organization_id, documentation: {type: 'integer', desc: '更改后机构id'} do |ins|
        ins.object_changes["organization_id"].last
      end
      expose :following_organization_name, documentation: {type: 'string', desc: '更改后机构名称'} do |_ins, opt|
        opt[:following_org]&.name
      end
    end

    expose :position_rank_id, as: :position, documentation: {type: 'integer', desc: '职级'} do |ins|
      ins.present_data("position_rank_id")
    end

    with_options(if: {type: PaperTrail::Version.news_feeds_type_value("member_change_position")}) do
      expose :previous_position, documentation: {type: 'integer', desc: '更改前职级'} do |ins|
        ins.present_data("position_rank_id")
      end
      expose :following_position, documentation: {type: 'integer', desc: '更改后职级'} do |ins|
        ins.object_changes["position_rank_id"].last
      end
    end

    expose :round_ids, documentation: {type: 'integer', desc: '关注轮次', is_array: true} do |ins|
      ins.present_data("round_ids")
    end
    expose :sector_ids, documentation: {type: 'integer', desc: '关注行业', is_array: true} do |ins|
      ins.present_data("sector_ids")
    end
  end
end
