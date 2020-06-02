class FundingUser < ApplicationRecord

  include StateConfig

  state_config :kind, config: {
      funding_project_users: {value: 1, desc: '项目成员'},
      bd_leader: {value: 2, desc: 'BD负责人'},
      execution_leader: {value: 3, desc: '执行负责人'},
  }

  belongs_to :funding
  belongs_to :user
end
