module Entities
  class FundingUser < Base
    expose :normal_users, with: Entities::User, documentation: {type: 'Entities::User', desc: '项目成员', is_array: true}
    expose :bd_leader, documentation: {type: 'Entities::User', desc: 'BD负责人'} do |ins|
      Entities::User.represent ins.bd_leader.first
    end
    expose :execution_leader, documentation: {type: 'Entities::User', desc: '执行负责人'} do |ins|
      Entities::User.represent ins.execution_leader.first
    end
  end
end