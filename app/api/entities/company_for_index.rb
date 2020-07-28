module Entities
  class CompanyForIndex < Base
    expose :id, documentation: {type: 'integer', desc: '公司id'}
    expose :name, documentation: {type: 'string', desc: '公司名称'}
    expose :sector_id, documentation: {type: 'integer', desc: '二级行业'}
    expose :parent_sector_id, documentation: {type: 'integer', desc: '一级行业'}
    expose :location_province_id, documentation: {type: 'integer', desc: '省份'}
    expose :recent_financing, documentation: {type: 'string', desc: '最近融资'} do |ins|
      self_financing_events = ins.fundings
      financing_events = Zombie::DmInvestevent.includes(:company, :invest_type, :invest_round, :investors).order_by_date.public_data.not_deleted.where(company_id: ins.id)._select(:id, :all_investors, :birth_date, :invest_type_and_batch_desc, :detail_money_des, :invest_round_id)
      all_events = (financing_events + self_financing_events).sort_by {|p| (p.try(:round_id) || p.try(:invest_round_id)).to_i}.reverse

      if all_events.empty?
        "-"
      else
        "#{all_events&.first.try(:invest_type_and_batch_desc) || ins.get_fa_round_name(all_events.first&.try(:round_id))}-#{all_events&.first.try(:detail_money_des) || ins.get_fa_target_amount(all_events.first)}"
      end
    end
    expose :callreport_num, documentation: {type: 'integer', desc: 'callreport数量'}
    expose :is_ka, documentation: {type: 'boolean', desc: '是否ka'}
    expose :is_chance, documentation: {type: 'boolean', desc: '是否有潜在融资需求'}
    with_options(format_with: :time_to_s_second) do
      expose :updated_at, documentation: {type: 'datetime', desc: '最近更新时间'}
    end
    expose :financing_events, documentation: {type: 'hash', desc: '融资事件'} do |ins, options|
      ins.financing_events("not_kun")
    end
    expose :one_sentence_intro, documentation: {type: 'string', desc: '一句话简介'}
    expose :fundings, documentation: {type: 'string', desc: '项目状态'} do |ins, options|
      ins.fundings.map do |e|
        {
          id: e.id,
          status: e.status
        }
      end
    end

    expose :tc_search_highlights, as: :search_highlights, documentation: {type: 'hash', desc: 'es结果高亮'}
  end
end
