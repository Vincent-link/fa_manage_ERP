class Notification < ApplicationRecord
  belongs_to :user

  include StateConfig

  state_config :project_type, config: {
      pass: {
        value: 1,
        desc: -> (before, after){"Title由\"#{before}\"改为\"#{after}\""},
        op: -> (user, verification){
          @user_title = UserTitle.find_by(name: verification.verifi["change"][1])
          user.update!(user_title_id: @user_title.id)
      }},
      pursue: {
        value: 2,
        desc: -> (funding){"#{funding}已启动BSC评分"},
        op: -> (user, params){
          Evaluation.create!(params) if user.is_ic?
      }},
      start_bsc: {value: 3, desc: -> (company){"#{company}申请进入KA"}, op: -> {}},
      asked: {value: 3, desc: -> (company){"#{company}申请进入KA"}, op: -> {}},
      answered: {value: 3, desc: -> (company){"#{company}申请进入KA"}, op: -> {}},
  }
end
