class Verification < ApplicationRecord
  include StateConfig

  state_config :verification_type, config: {
      title_update: {value: 1, desc: 'Title修改', op: -> (user, verification){
        @user_title = UserTitle.find_by(name: verification.verifi["change"][1])
        user.update!(user_title_id: @user_title.id)
        }},
      bsc_evaluate: {value: 2, desc: 'BSC评分', op: -> (user, params){
        binding.pry
        Evaluation.create!(params) if user.is_ic?
        }},
      ka_apply: {value: 3, desc: 'KA申请'},
      appointment_apply: {value: 4, desc: '约见申请'},
      post_question: {value: 5, desc: ' 提交问题', op: -> (user, params){
        Question.create!(params) if user.is_ic?
        }},
  }

  # enum status: [:processed, :resolved]
  # enum verification_type: [:title_update, :bsc_evaluate, :ka_apply, :appointment_apply]
end
