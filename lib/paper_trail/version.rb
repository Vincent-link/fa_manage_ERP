module PaperTrail
  class Version < ApplicationRecord
    include StateConfig
    include PaperTrail::VersionConcern
    attr_accessor :type

    MEMBER_TYPE = ["member_change_org", "member_change_position", "member_create", "member_retire"]
    ORG_TYPE = ["org_ir_review", "org_create"]

    state_config :news_feeds_type, config: {
      member_change_org: {
          value: 1,
          desc: '机构变更',
          fit: -> (ins){ins.event == "update" && ins.item_type == "Member" && ins.object_changes&.keys&.include?("organization_id")}
      },
      member_change_position: {
          value: 2,
          desc: '职位变更',
          fit: -> (ins){ins.event == "update" && ins.item_type == "Member" && ins.object_changes&.keys&.include?("position")}
      },
      member_create: {
          value: 3,
          desc: '新增一位投资人',
          fit: -> (ins){ins.event == "create" && ins.item_type == "Member"}
      },
      member_retire: {
          value: 4,
          desc: '离职一位投资人',
          fit: -> (ins){ins.event == "update" &&
              ins.item_type == "Member" &&
              !ins.object_changes&.keys&.include?("organization_id")
              ins.object_changes&.keys&.include?("is_dimission") &&
              ins.object_changes["is_dimission"][1]
          }
      },
      org_ir_review: {
          value: 5,
          desc: '投资机构IR_Review',
          fit: -> (ins){ins.event == "create" &&
              ins.item_type == "Comment" &&
              ins.object_changes["type"][1] == "IrReview" &&
              ins.object_changes["commentable_type"][1] == "Organization"}
      },
      org_create: {
          value: 6,
          desc: '新增一个投资机构',
          fit: -> (ins){ins.event == "create" && ins.item_type == "Organization"}
      }
    }

    def self.version_type_attach(ins, event_filter)
      MEMBER_TYPE.each {|member_type| ins.type = news_feeds_type_value(member_type) if send(("news_feeds_type_" + member_type + "_fit")).send(:call, ins) && event_filter.in?(["member", nil])}
      ORG_TYPE.each {|org_type| ins.type = news_feeds_type_value(org_type) if send(("news_feeds_type_" + org_type + "_fit")).send(:call, ins) && event_filter.in?(["organization", nil])}
      ins.type
    end
  end
end
