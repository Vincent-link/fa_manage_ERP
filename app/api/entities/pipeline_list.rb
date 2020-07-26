module Entities
  class PipelineListBase < Base
    expose :id, documentation: {type: 'integer', desc: 'Pipeline id'} do |obj|
      obj[:id]
    end
    expose :status_desc, documentation: {type: 'string', desc: 'Pipeline阶段'} do |obj|
      obj[:status_desc]
    end
    expose :funding_id, documentation: {type: 'integer', desc: '项目id'} do |obj|
      obj[:funding_id]
    end
    expose :funding_name, documentation: {type: 'string', desc: '项目名称'} do |obj|
      obj[:funding_name]
    end
    expose :funding_status_desc, documentation: {type: 'string', desc: '项目状态'} do |obj|
      obj[:funding_status_desc]
    end
    expose :last_updated_day, documentation: {type: 'integer', desc: '上次更新'} do |obj|
      obj[:last_updated_day]
    end
    expose :funding_category, as: :name, documentation: {type: 'string', desc: '产品'} do |obj|
      obj[:name]
    end
    expose :teams, documentation: {type: 'string', desc: 'FA负责小组', is_arry: true} do |obj|
      obj[:funding_member_teams]
    end
    expose :company_sectors, documentation: {type: 'string', desc: '所属行业', is_arry: true} do |obj|
      obj[:company_sectors]
    end
    expose :is_list_company, documentation: {type: 'boolean', desc: '是否是上市公司', is_arry: true} do |obj|
      obj[:is_list_company]
    end
    expose :est_amount_currency, documentation: {type: 'integer', desc: '币种'} do |obj|
      obj[:est_amount_currency]
    end
    expose :est_amount, documentation: {type: 'float', desc: '总交易规模'} do |obj|
      obj[:est_amount]
    end
    expose :funding_source_desc, documentation: {type: 'string', desc: '来源部门'} do |obj|
      obj[:funding_funding_source_desc]
    end
    expose :total_fee, documentation: {type: 'float', desc: '项目总收费'} do |obj|
      obj[:total_fee_rmb]
    end
    expose :execution_day, documentation: {type: 'integer', desc: '执行天数'} do |obj|
      obj[:execution_day]
    end
    expose :bu_rate, documentation: {type: 'float', desc: '本BU分成比例'} do |obj|
      obj[:bu_rate]
    end
    expose :el_date, documentation: {type: 'date', desc: '签EL/启动日期'} do |obj|
      obj[:el_date]
    end
  end

  class PipelineList < PipelineListBase
    expose :bu_total_fee_rmb, documentation: {type: 'float', desc: '本BU收费金额'} do |obj|
      obj[:bu_total_fee_rmb]
    end
    expose :complete_rate, documentation: {type: 'float', desc: '年内收入完成概率'} do |obj|
      obj[:complete_rate]
    end
    expose :bu_rate_income_rmb, documentation: {type: 'float', desc: '本BU概率收入'} do |obj|
      obj[:bu_rate_income_rmb]
    end
    expose :est_bill_date, documentation: {type: 'date', desc: '预计开账单日期'} do |obj|
      obj[:est_bill_date]
    end
  end

  class PipelineListForPass < PipelineListBase
    expose :funding_operating_day, documentation: {type: 'date', desc: '进入Hold日期'} do |obj, opt|
      obj[:funding_operating_day]
    end
  end
end
