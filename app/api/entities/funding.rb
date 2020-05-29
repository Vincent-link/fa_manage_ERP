module Entities
  class Funding < Base
    expose :id, documentation: {type: 'integer', desc: '项目id'}
    expose :name, documentation: {type: 'string', desc: '项目名称'}
    expose :serial_number, documentation: {type: 'string', desc: '项目编号'}
    expose :funding_score, documentation: {type: 'integer', desc: '项目评分'}
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
    expose :target_amount, documentation: {type: 'float', desc: '交易金额'}
    expose :is_ka, documentation: {type: 'boolean', desc: '是否是KA项目'}
    expose :is_complicated, documentation: {type: 'boolean', desc: '是否是复杂项目'}
    expose :project_users, with: Entities::User, documentation: {type: 'Entities::User', desc: '项目成员'}
    expose :bd_leader, documentation: {type: 'Entities::User', desc: 'BD负责人'} do |ins|
      Entities::User.represent ins.bd_leader.first
    end
    expose :execution_leader, documentation: {type: 'Entities::User', desc: '执行负责人'} do |ins|
      Entities::User.represent ins.bd_leader.first
    end
    expose :operating_days do |ins|
      (Date.today - ins.time_lines.first.created_at.to_date).to_i
    end
    expose :com_desc, documentation: {type: 'string', desc: '公司简介'}
    expose :products_and_business, documentation: {type: 'string', desc: '产品与商业模式'}
    expose :financial, documentation: {type: 'string', desc: '财务数据'}
    expose :operational, documentation: {type: 'string', desc: '运营数据'}
    expose :market_competition, documentation: {type: 'string', desc: '市场竞争分析'}
    expose :financing_plan, documentation: {type: 'string', desc: '融资计划'}
    expose :other_desc, documentation: {type: 'string', desc: '其他'}
    expose :sources_type, documentation: {type: 'integer', desc: '融资来源类型'}
    expose :sources_detail, documentation: {type: 'string', desc: '融资来源明细'}
    expose :confidentiality_level, documentation: {type: 'integer', desc: '保密等级'}
    expose :confidentiality_reason, documentation: {type: 'string', desc: '保密原因'}
    expose :is_reportable, documentation: {type: 'boolean', desc: '是否出现在周报/日报'}
  end
end