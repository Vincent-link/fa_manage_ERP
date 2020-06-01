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
    expose :round_id, documentation: {type: 'integer', desc: '轮次'}
    expose :operating_days do |ins|
      (Date.today - ins.time_lines.first.created_at.to_date).to_i
    end
    expose :project_users, with: Entities::User, documentation: {type: 'Entities::User', desc: '项目成员', is_array: true}
    expose :company, with: Entities::CompanyBaseInfo, documentation: {type: 'Entities::CompanyBaseInfo', desc: '公司信息'}
    expose :target_amount, documentation: {type: 'float', desc: '交易金额'}
    # todo tracklog
    # todo 约见
  end
end