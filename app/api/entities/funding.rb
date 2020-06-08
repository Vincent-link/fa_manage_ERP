module Entities
  class Funding < Base
    expose :id, documentation: {type: 'integer', desc: '项目id'}
    expose :name, documentation: {type: 'string', desc: '项目名称'}
    expose :serial_number, documentation: {type: 'string', desc: '项目编号'}
    expose :funding_score, documentation: {type: 'integer', desc: '项目评分'}
    expose :company, with: Entities::CompanyBaseInfo, documentation: {type: 'Entities::CompanyBaseInfo', desc: '公司信息'}
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
    expose :target_amount, documentation: {type: 'float', desc: '交易金额'}
    expose :target_amount_currency, documentation: {type: 'integer', desc: '交易金额币种'}
    expose :post_investment_valuation, documentation: {type: 'float', desc: '本轮投后估值'}
    expose :post_valuation_currency, documentation: {type: 'integer', desc: '本轮投后估值币种'}
    expose :is_ka, documentation: {type: 'boolean', desc: '是否是KA项目'}
    expose :is_complicated, documentation: {type: 'boolean', desc: '是否是复杂项目'}
    expose :normal_users, with: Entities::User, documentation: {type: 'Entities::User', desc: '项目成员', is_array: true}
    expose :bd_leader, documentation: {type: 'Entities::User', desc: 'BD负责人'} do |ins|
      Entities::User.represent ins.bd_leader.first
    end
    expose :execution_leader, documentation: {type: 'Entities::User', desc: '执行负责人'} do |ins|
      Entities::User.represent ins.execution_leader.first
    end
    with_options(format_with: :time_to_s_date) do
      expose :operating_day, documentation: {type: 'string', desc: '状态开始时间'}
    end
    expose :shiny_word, documentation: {type: 'string', desc: '一句话简介'}
    expose :com_desc, documentation: {type: 'string', desc: '公司简介'}
    expose :products_and_business, documentation: {type: 'string', desc: '产品与商业模式'}
    expose :financial, documentation: {type: 'string', desc: '财务数据'}
    expose :operational, documentation: {type: 'string', desc: '运营数据'}
    expose :market_competition, documentation: {type: 'string', desc: '市场竞争分析'}
    expose :financing_plan, documentation: {type: 'string', desc: '融资计划'}
    expose :other_desc, documentation: {type: 'string', desc: '其他'}
    expose :source_type, documentation: {type: 'integer', desc: '融资来源类型'}
    expose :source_detail, if: lambda { |ins| 'Funding'.constantize.source_type_filter(:find_company, :company_find, :colleague_introduction).include? ins.source_type}, documentation: {type: 'string', desc: '融资来源明细'}
    expose :source_member, if: lambda { |ins| 'Funding'.constantize.source_type_filter(:member_referral, :member_recommend).include? ins.source_type}, documentation: {type: 'Entities::IdName', desc: '投资者'} do |ins|
      {
          id: ins.source_member,
          name: ins.funding_source_member&.name
      }
    end
    expose :confidentiality_level, documentation: {type: 'integer', desc: '保密等级'}
    expose :confidentiality_reason, documentation: {type: 'string', desc: '保密原因'}
    expose :is_reportable, documentation: {type: 'boolean', desc: '是否出现在周报/日报'}
    expose :is_list, documentation: {type: 'boolean', desc: '是否为上市/新三板公司'}
    expose :ticker, documentation: {type: 'string', desc: '股票代码'}
  end
end