module Entities
  class NewsFeeds < Base
    expose :type, documentation: {type: 'integer', desc: "类型：" + PaperTrail::Version.news_feeds_type_hash.inspect}
    expose :type_name, documentation: {type: 'string', desc: '类型名称'} do |ins|
      PaperTrail::Version.news_feeds_type_desc_for_value(ins.type)
    end
    expose :whodunnit, documentation: {type: 'string', desc: '更新人'}
    expose :created_at, format_with: :c_md_hm, documentation: {type: Time, desc: '更新时间'}
    expose :member, if: lambda { |ins| ins.type.in?(PaperTrail::Version::MEMBER_TYPE.map{|type| PaperTrail::Version.news_feeds_type_value(type)}) },
           documentation: {type: Entities::MemberForNewsFeeds, desc: '投资人'} do |ins|
      Entities::MemberForNewsFeeds.represent ins.item, options.merge(type: ins.type, changes: ins.object_changes)
    end
    expose :organization, if: lambda { |ins| ins.type.in?(PaperTrail::Version::ORG_TYPE.map{|type| PaperTrail::Version.news_feeds_type_value(type)}) },
           documentation: {type: Entities::OrganizationForNewsFeeds, desc: '机构'} do |ins|
      Entities::OrganizationForNewsFeeds.represent ins.item, options.merge(type: ins.type, changes: ins.object_changes)
    end
  end
end
