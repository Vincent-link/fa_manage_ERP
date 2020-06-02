module Entities
  class FundingStatusTransition < Base
    expose :id, documentation: {type: 'integer', desc: '项目id'}
    expose :com_desc, documentation: {type: 'string', desc: '公司简介'}
    expose :products_and_business, documentation: {type: 'string', desc: '产品与商业模式'}
    expose :financial, documentation: {type: 'string', desc: '财务数据'}
    expose :operational, documentation: {type: 'string', desc: '运营数据'}
    expose :market_competition, documentation: {type: 'string', desc: '市场竞争分析'}
    expose :financing_plan, documentation: {type: 'string', desc: '融资计划'}
    expose :other_desc, documentation: {type: 'string', desc: '其他'}
    expose :bp, with: Entities::File,if: ->(ins) {ins.bp.present?}, documentation: {type: Entities::File, desc: 'bp文件', required: true}
    expose :is_list, documentation: {type: 'boolean', desc: '是否为上市/新三板公司'}
    expose :ticker, documentation: {type: 'string', desc: '股票代码'}
    expose :post_investment_valuation, documentation: {type: 'float', desc: '本轮投后估值'}
    expose :post_valuation_currency, documentation: {type: 'integer', desc: '本轮投后估值币种'}



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
  end
end