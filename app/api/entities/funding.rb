module Entities
  class Funding < Base
    expose :id, documentation: {type: 'integer', desc: '项目id'}
    expose :company, with: Entities::CompanyBaseInfo, documentation: {type: 'Entities::CompanyBaseInfo', desc: '公司信息'}
    expose :status, documentation: {type: 'json', desc: '状态'} do |ins|
      {
          id: ins.status,
          name: ins.status_desc
      }
    end


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
  end
end