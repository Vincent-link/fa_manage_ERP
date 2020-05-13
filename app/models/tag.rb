class Tag < ApplicationRecord
  include StateConfig

  state_config :category, config: {
      member_hot_spot: {value: 1, desc: '投资人热点'},
  }
end
