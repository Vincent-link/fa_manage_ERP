module Entities
  class FinancingEvents < Base
    with_options(format_with: :time_to_s_second) do
      expose :date, documentation: {type: 'string', desc: '更新时间', required: true}
    end
    expose :round_id, documentation: {type: 'string', desc: '', required: true}
    expose :target_amount, documentation: {type: 'string', desc: '', required: true}
    expose :funding_members, documentation: {type: 'string', desc: '', required: true}
    expose :status, documentation: {type: 'string', desc: '', required: true}

    # expose :birth_date, if: lambda {|ins| ins.class.name == "Zombie::DmInvestevent"}, documentation: {type: 'string', desc: '更新时间', required: true}
    # expose :invest_type_and_batch_desc, if: lambda {|ins| ins.class.name == "Zombie::DmInvestevent"}, documentation: {type: 'string', desc: '', required: true}
    # expose :detail_money_des, if: lambda {|ins| ins.class.name == "Zombie::DmInvestevent"}, documentation: {type: 'string', desc: '', required: true}
    # expose :all_investors, if: lambda {|ins| ins.class.name == "Zombie::DmInvestevent"}, documentation: {type: 'string', desc: '', required: true} do |ins|
    #   ins.all_investors.map { |e| {name: e.fromable_name} }
    # end
    # expose :event, if: lambda {|ins| ins.class.name == "Zombie::DmInvestevent"}, documentation: {type: 'string', desc: '', required: true} do |ins|
    #   "融资事件"
    # end
  end
end
