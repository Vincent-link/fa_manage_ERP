module Entities
  class FundingBaseInfo < Base
    expose :id, documentation: {type: 'integer', desc: '项目id'}
    expose :name, documentation: {type: 'string', desc: '项目名称'}
    expose :shiny_word, documentation: {type: 'string', desc: '一句话两点'}
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
    expose :operating_days do |ins|
      (Date.today - ins.time_lines.first.created_at.to_date).to_i
    end
    expose :company, with: Entities::CompanyBaseInfo, documentation: {type: 'Entities::CompanyBaseInfo', desc: '公司信息'}
    expose :target_amount, documentation: {type: 'float', desc: '交易金额'}
  end
end