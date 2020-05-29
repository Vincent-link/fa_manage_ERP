class Verification < ApplicationRecord
  belongs_to :user

  include StateConfig

  state_config :verification_type, config: {
      title_update: {
        value: 1,
        desc: -> (before, after){"Title由\"#{before}\"改为\"#{after}\""},
        op: -> (user, verification){
          @user_title = UserTitle.find_by(name: verification.verifi["change"][1])
          user.update!(user_title_id: @user_title.id)
      }},
      bsc_evaluate: {
        value: 2,
        desc: -> (funding){"【#{funding}】已启动BSC评分"},
        op: -> (user, params){
          evaluation = Evaluation.find_by(user_id: user.id, funding_id: params[:funding_id])
          evaluation.update(params) unless evaluation.nil?
          evaluation
      }},
      ka_apply: {value: 3, desc: -> (company){"#{company}申请进入KA"}, op: -> {}},
      appointment_apply: {value: 4, desc: -> (company, appoint_time){"#{company}申请约见（#{appoint_time}）"}, op: -> {}},
      post_question: {value: 5, desc: '提交问题', op: -> (user, params){
        evaluation = Evaluation.find_by(user_id: user.id, funding_id: params[:funding_id])
        Question.create!(params) unless evaluation.nil?
      }},
  }
end
