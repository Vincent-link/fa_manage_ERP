module Entities
  class FundingStatusTransition < Base
    expose :id, documentation: {type: 'integer', desc: '项目id'}
    expose :com_desc, documentation: {type: 'string', desc: '公司简介'}
    expose :products_and_business, documentation: {type: 'string', desc: '产品与商业模式'}
    expose :financial, documentation: {type: 'string', desc: '财务数据'}
    expose :operational, documentation: {type: 'string', desc: '运营数据'}
    expose :market_competition, documentation: {type: 'string', desc: '市场竞争分析'}
    expose :financing_plan, documentation: {type: 'string', desc: '融资计划'}
    expose :team_desc, documentation: {type: 'string', desc: '团队介绍'}
    expose :other_desc, documentation: {type: 'string', desc: '其他'}
    expose :funding_bp, with: Entities::File,if: ->(ins) {ins.funding_bp.present?}, documentation: {type: Entities::File, desc: 'bp文件', required: true}
    expose :is_list, documentation: {type: 'boolean', desc: '是否为上市/新三板公司'}
    expose :ticker, documentation: {type: 'string', desc: '股票代码'}
    expose :post_investment_valuation, documentation: {type: 'float', desc: '本轮投后估值'}
    expose :post_valuation_currency, documentation: {type: 'integer', desc: '本轮投后估值币种'}
  end
end