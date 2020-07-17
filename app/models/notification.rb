class Notification < ApplicationRecord
  belongs_to :user, optional: true

  include StateConfig

  state_config :project_type, config: {
      passed: {
        value: 1,
        desc: -> (project){"【#{project}】未通过BSC投票，项目移动到Pass"
      }},
      pursued: {
        value: 2,
        desc: -> (project){"【#{project}】项目已经被管理员移动到Pursue阶段"
      }},
      bsc_started: {value: 3, desc: -> (project){"【#{project}】项目已启动BSC"}},
      answered: {value: 4, desc: -> (project){"您在【#{project}】项目发起的提问已被回答，去查看"}, op: -> {}},
      ask_to_review: {value: 5, desc: -> (project){"【#{project}】项目已启动BSC，去查看详情"}, op: -> {}},
      waitting: {value: 6, desc: -> (project){"【#{project}】已完成BSC投票，赞成票+中立票数之和=反对票，待管理员手动推进"}, op: -> {}},
      after_question: {value: 7, desc: -> (project){"投委会在【#{project}】 项目发起了提问。"} }
  }

  state_config :investor_type, config: {
      position_change: {
        value: 1,
        desc: -> (user_name, before, after){"【#{user_name}】职位变更：#{before} -> #{after}"}
      },
      institutional_change: {
        value: 2,
        desc: -> (user_name, before, after){"【#{user_name}】机构变更：#{before} -> #{after}"}
      },
      resign: {
        value: 3,
        desc: -> (user_name, organization_name){"#{user_name}从【#{organization_name}】离职"}
      },
  }

  state_config :notification_type, config: {
      ir_review: {
        value: 1,
        desc: "ir_review",
        content: -> (user_name, funding_name){"#{user_name}为【#{funding_name}】 添加了IR Review。"}
      },
      project: {
        value: 2,
        desc: "project"
      },
      investor: {
        value: 3,
        desc: "investor",
      }
  }
end
