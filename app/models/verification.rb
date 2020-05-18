class Verification < ApplicationRecord
  include StateConfig
  state_config :verification_type, config: {
      title_update: {value: 1, desc: 'Title修改'},
      BSC_evaluate: {value: 2, desc: 'BSC评分'},
      KA_apply: {value: 3, desc: 'KA申请'},
      appointment_apply: {value: 4, desc: '约见申请'},
  }
end
