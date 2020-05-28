module Entities
  class FundingLite < Base
    expose :id, documentation: {type: 'integer', desc: '项目id'}
    expose :category, documentation: {type: 'json', desc: '项目类型'} do |ins|
      {
          id: ins.category,
          name: ins.category_desc
      }
    end
    expose :round, documentation: {type: 'json', desc: '轮次'} do |ins|
      {
          id: ins.round_id,
          name: CacheBox.dm_single_rounds[ins.round_id]
      }
    end
    expose :company, with: Entities::CompanyLite, documentation: {type: 'Entities::CompanyLite', desc: '公司信息'}
  end
end