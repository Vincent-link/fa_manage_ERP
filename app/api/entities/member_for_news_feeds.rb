module Entities
  class MemberForNewsFeeds < Base
    expose :id, documentation: {type: 'integer', desc: '投资人id'}
    expose :name, documentation: {type: 'string', desc: '投资人名称'}
    expose :organization_id, documentation: {type: 'integer', desc: '机构id', required: true}
    expose :organization_name, documentation: {type: 'string', desc: '机构名称', required: true}
    expose :previous_organization_id, if: {type: PaperTrail::Version.news_feeds_type_value("member_change_org")}, documentation: {type: 'integer', desc: '更改前机构id'} do |_ins, opt|
      opt[:changes]["organization_id"].first
    end
    expose :previous_organization_name, if: {type: PaperTrail::Version.news_feeds_type_value("member_change_org")}, documentation: {type: 'string', desc: '更改前机构名称'} do |_ins, opt|
      Organization.find_by_id(opt[:changes]["organization_id"].first)&.name
    end
    expose :following_organization_id, if: {type: PaperTrail::Version.news_feeds_type_value("member_change_org")}, documentation: {type: 'integer', desc: '更改后机构id'} do |_ins, opt|
      opt[:changes]["organization_id"].last
    end
    expose :following_organization_name, if: {type: PaperTrail::Version.news_feeds_type_value("member_change_org")}, documentation: {type: 'string', desc: '更改后机构名称'} do |_ins, opt|
      Organization.find_by_id(opt[:changes]["organization_id"].last)&.name
    end
    expose :position, documentation: {type: 'string', desc: '职位'}
    expose :previous_position, if: {type: PaperTrail::Version.news_feeds_type_value("member_change_position")}, documentation: {type: 'string', desc: '更改前职位'} do |_ins, opt|
      opt[:changes]["position"].first
    end
    expose :following_position, if: {type: PaperTrail::Version.news_feeds_type_value("member_change_position")}, documentation: {type: 'string', desc: '更改后职位'} do |_ins, opt|
      opt[:changes]["position"].last
    end
    expose :round_ids, documentation: {type: 'integer', desc: '关注轮次', is_array: true}
    expose :sector_ids, documentation: {type: 'integer', desc: '关注行业', is_array: true}
  end
end
