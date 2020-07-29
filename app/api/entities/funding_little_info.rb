module Entities
  class FundingLittleInfo < Base
    expose :id, documentation: {type: 'integer', desc: '项目id'}
    expose :name, documentation: {type: 'string', desc: '项目名称'}
    expose :status, documentation: {type: 'Entities::IdName', desc: '状态'} do |ins|
      {
          id: ins.status,
          name: ins.status_desc
      }
    end
    expose :category, documentation: {type: 'Entities::IdName', desc: '项目类型'} do |ins|
      {
          id: ins.category,
          name: ins.category_desc
      }
    end
    expose :round_id, documentation: {type: 'integer', desc: '轮次'}
  end
end