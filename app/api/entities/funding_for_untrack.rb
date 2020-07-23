module Entities
  class FundingForUntrack < FundingLite
    expose :status, documentation: {type: 'integer', desc: '项目状态'}
    expose :sector_id, documentation: {type: 'integer', desc: '行业id'}
    expose :user_names, documentation: {type: 'string', desc: '项目成员'}
    expose :member_in_sector, documentation: {type: Entities::MemberLite, desc: '关注该领域的投资人', is_array: true} do |f, options|
      Entities::MemberLite.represent options[:members].select {|m| (m.sector_ids || []).include?(f.sector_id)}
    end
  end
end