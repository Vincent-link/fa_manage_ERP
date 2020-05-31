class Verification < ApplicationRecord
  belongs_to :user

  include StateConfig

  state_config :verification_type, config: {
      title_update: {
        value: 1,
        desc: -> (before, after){"Title由\"#{before}\"改为\"#{after}\""},
        op: -> (params, verification){
          user_title_before = User.current.user_title.name unless User.current.user_title.nil?
          @user_title = UserTitle.find(params[:user_title_id])
          desc = Verification.verification_type_config[:title_update][:desc].call(user_title_before, @user_title.name)

          if !verification.nil?
            verification.update(desc: desc, verifi: {kind: "title_update", change: [user_title_before, @user_title.name]}) unless verification.verifi["change"][1] == @user_title.name
          else
            Verification.create(user_id: User.current.id, sponsor: User.current.id, verification_type: "title_update", desc: desc, verifi: {kind: "title_update", change: [user_title_before, @user_title.name]})
          end
      }},
      bsc_evaluate: {
        value: 2,
        desc: -> (funding){"【#{funding}】已启动BSC评分"},
        op: -> (params){
          evaluation = Evaluation.find_by(user_id: User.current.id, funding_id: params[:funding_id])
          evaluation.update(params) unless evaluation.nil?
          evaluation
      }},
      ka_apply: {value: 3, desc: -> (company){"#{company}申请进入KA"}, op: -> {}},
      appointment_apply: {value: 4, desc: -> (company, appoint_time){"#{company}申请约见（#{appoint_time}）"}, op: -> {}},
      post_question: {
        value: 5,
        desc: '提交问题',
        op: -> (params){
          evaluation = Evaluation.find_by(user_id: User.current, funding_id: params[:funding_id])
          Question.create!(params.merge(evaluation_id: evaluation.id)) unless evaluation.nil?
      }},
  }
end
