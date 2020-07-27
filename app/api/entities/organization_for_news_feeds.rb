module Entities
  class OrganizationForNewsFeeds < Base
    expose :id, if: {type: PaperTrail::Version.news_feeds_type_value("org_create")}, documentation: {type: 'integer', desc: '机构id'}
    expose :name, if: {type: PaperTrail::Version.news_feeds_type_value("org_create")}, documentation: {type: 'string', desc: '机构名称'}
    expose :logo, if: {type: PaperTrail::Version.news_feeds_type_value("org_create")}, documentation: {type: 'string', desc: '机构logo url'} do |ins|
      ins.logo_attachment&.service_url
    end
    expose :round_ids, if: {type: PaperTrail::Version.news_feeds_type_value("org_create")}, documentation: {type: 'integer', desc: '关注轮次', is_array: true}
    expose :sector_ids, if: {type: PaperTrail::Version.news_feeds_type_value("org_create")}, documentation: {type: 'integer', desc: '关注行业', is_array: true}

    expose :id, if: {type: PaperTrail::Version.news_feeds_type_value("org_ir_review")}, documentation: {type: 'integer', desc: '机构id'} do |ins|
      ins.commentable.id
    end
    expose :name, if: {type: PaperTrail::Version.news_feeds_type_value("org_ir_review")}, documentation: {type: 'string', desc: '机构名称'} do |ins|
      ins.commentable.name
    end
    expose :logo, as: :logo, if: {type: PaperTrail::Version.news_feeds_type_value("org_ir_review")}, documentation: {type: 'string', desc: '机构logo url'} do |ins|
      ins.commentable&.logo_attachment&.service_url
    end
    expose :content, if: {type: PaperTrail::Version.news_feeds_type_value("org_ir_review")}, documentation: {type: 'string', desc: 'IrReview'}
  end
end
