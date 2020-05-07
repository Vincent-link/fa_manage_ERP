module Entities
  class InvesteventForIndex < Base
    expose :id, documentation: {type: 'integer', desc: '案例id', required: true}
    expose :company_name, as: :name, documentation: {type: 'string', desc: '案例名称', required: true}
    expose :invest_round_id, documentation: {type: 'integer', desc: '轮次id', required: true}
    expose :invest_type_id, documentation: {type: 'integer', desc: '融资类型id', required: true}
    expose :birth_date, as: :date, documentation: {type: 'date', desc: '案例时间', required: true}
    expose :company_id, documentation: {type: 'integer', desc: '公司id'}

    #todo add_company_round
    expose :invest_round_id, as: :company_round_id, documentation: {type: 'integer', desc: '最新轮次id', required: true}

    expose :detail_money_des, documentation: {type: 'string', desc: '融资额度'}
    expose :company_category_id, as: :sector_id, documentation: {type: 'integer', desc: '行业id'}

    #todo add_investors
    expose :investors, documentation: {type: 'string', desc: '投资方'} do |ins|
      [{
           id: 4,
           name: '假数据'
       },
       {
           id: 2,
           name: '假数据2'
       }
      ]
    end
  end
end