class Notification < ApplicationRecord
  belongs_to :user

  include StateConfig

  state_config :project_type, config: {
      passed: {
        value: 1,
        desc: -> (project){"#{project}项目还有3天将会被Pass"
      }},
      pursued: {
        value: 2,
        desc: -> (project){"#{project}项目已经被管理员移动到Pursue阶段"
      }},
      bsc_started: {value: 3, desc: -> (project){"【#{project}】项目已启动BSC"}},
      answered: {value: 3, desc: -> (project){"您在【#{project}】项目发起的提问已被回答，去查看"}, op: -> {}},
      ask_to_review: {value: 3, desc: -> (project){"【#{project}】项目已启动BSC，去查看详情"}, op: -> {}},
  }
end
