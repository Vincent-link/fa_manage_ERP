module Entities
  class OrganizationForNewsFeeds < Base
    with_options(if: {type: PaperTrail::Version.news_feeds_type_value("org_create")}) do
      expose :id, documentation: {type: 'integer', desc: '机构id'} do |ins|
        ins.item.id
      end
      expose :name, documentation: {type: 'string', desc: '机构名称'} do |ins|
        ins.present_data("name")
      end
      expose :logo, documentation: {type: 'string', desc: '机构logo url'} do |ins|
        ins.item.logo_attachment&.service_url
      end

      expose :round_ids, documentation: {type: 'integer', desc: '关注轮次', is_array: true} do |ins|
        ins.present_data("round_ids")
      end
      expose :sector_ids, documentation: {type: 'integer', desc: '关注行业', is_array: true} do |ins|
        ins.present_data("sector_ids")
      end
    end

    with_options(if: {type: PaperTrail::Version.news_feeds_type_value("org_ir_review")}) do
      expose :id, documentation: {type: 'integer', desc: '机构id'} do |ins|
        ins.item.commentable&.id
      end
      expose :name, documentation: {type: 'string', desc: '机构名称'} do |ins|
        ins.item.commentable&.name
      end
      expose :logo, documentation: {type: 'string', desc: '机构logo url'} do |ins|
        ins.item.commentable&.logo_attachment&.service_url
      end
      expose :content, documentation: {type: 'string', desc: 'IrReview'} do |ins|
        ins.present_data("content")
      end
    end
  end
end
