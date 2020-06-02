module Entities
  class InvesteventForIndex < Base
    expose :id, documentation: {type: 'integer', desc: '案例id', required: true}
    expose :company_name, as: :name, documentation: {type: 'string', desc: '案例名称', required: true}
    expose :invest_round_id, documentation: {type: 'integer', desc: '轮次id', required: true}
    expose :invest_type_id, documentation: {type: 'integer', desc: '融资类型id', required: true}
    expose :birth_date, as: :date, documentation: {type: 'date', desc: '案例时间', required: true}
    expose :company_id, documentation: {type: 'integer', desc: '公司id'}

    expose :company_round_id, documentation: {type: 'integer', desc: '最新轮次id', required: true} do |ins|
      ins.overview&.current_invest_round_id
    end

    expose :detail_money_des, documentation: {type: 'string', desc: '融资额度'}
    expose :company_category_id, as: :sector_id, documentation: {type: 'integer', desc: '行业id'}

    expose :investor_relation do |ins|
      rel = ins.investevent_investors&.first
      if rel
        {
            investment_money: rel.investment_money,
            investment_ratio: rel.investment_ratio,
            investor_id: rel.investor_id,
            investor_name: rel.investor_name
        }
      end
    end

    expose :investors, documentation: {type: 'string', desc: '投资方'} do |ins|
      if ins.investevent_investors
        ins.investevent_investors.map do |rel|
          {
              id: rel.investor_id,
              name: rel.investor_name
          }
        end
      end
    end
  end
end