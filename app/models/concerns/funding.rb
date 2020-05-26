module Concerns::Funding
  module Status
    extend ActiveSupport::Concern
    include Concerns::StateConfig

    state_config :category, config: {
        pp:       {value: 1, desc: 'PP'},
        ma:       {value: 2, desc: 'M&A'},
        advisory: {value: 3, desc: '咨询'}
    }
  end
end

