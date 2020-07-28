module Entities
  class OrganizationForNewsFeeds < Base
    with_options(if: {type: PaperTrail::Version.news_feeds_type_value("org_create")}) do
      expose :id, documentation: {type: 'integer', desc: '机构id'}
      expose :name, documentation: {type: 'string', desc: '机构名称'}
      expose :logo, documentation: {type: 'string', desc: '机构logo url'} do |ins|
        ins.logo_attachment&.service_url
      end
      expose :round_ids, documentation: {type: 'integer', desc: '关注轮次', is_array: true}
      expose :sector_ids, documentation: {type: 'integer', desc: '关注行业', is_array: true}
    end

    with_options(if: {type: PaperTrail::Version.news_feeds_type_value("org_ir_review")}) do
      expose :id, documentation: {type: 'integer', desc: '机构id'} do |ins|
        ins.commentable&.id
      end
      expose :name, documentation: {type: 'string', desc: '机构名称'} do |ins|
        ins.commentable&.name
      end
      expose :logo, documentation: {type: 'string', desc: '机构logo url'} do |ins|
        ins.commentable&.logo_attachment&.service_url
      end
      expose :content, documentation: {type: 'string', desc: 'IrReview'}
    end
  end
end
