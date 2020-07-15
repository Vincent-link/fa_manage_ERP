class Verification < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :verifyable, polymorphic: true, optional: true

  include StateConfig

  state_config :verification_type, config: {
      title_update: {
        value: 1,
        desc: -> (before, after){"Title由\"#{before}\"改为\"#{after}\""},
        op: -> (verification){
          user_title = UserTitle.find_by(name: verification.verifi["change"][1])
          User.find(verification.sponsor).update(user_title_id: user_title.id)
        },
        resource: "admin_read_title_update_verification"
      },
      bsc_evaluate: {
        value: 2,
        desc: -> (funding){"【#{funding}】已启动BSC评分"},
        op: -> (params){
          evaluation = Evaluation.find_by(user_id: User.current.id, funding_id: params[:funding_id])
          raise "不能重复提交" unless evaluation.try(:is_agree).nil?
          evaluation.update(params.merge(number: evaluation.get_number)) unless evaluation.nil?
      }},
      ka_apply: {value: 3, desc: -> (company){"#{company}申请进入KA"}, op: -> {}},
      appointment_apply: {value: 4, desc: -> (company, appoint_time){"#{company}申请约见（#{appoint_time}）"}, op: -> {}},
      post_question: {
        value: 5,
        desc: -> (funding){"【#{funding}】已启动BSC，请查看项目信息并提问"},
        op: -> (params){
          evaluation = Evaluation.find_by(user_id: User.current.id, funding_id: params[:funding_id])
          Question.create!(params.merge(evaluation_id: evaluation.id, user_id: User.current.id)) unless evaluation.nil?

          funding = Funding.find(params[:funding_id])
          content = Notification.notification_type_config[:after_question][:desc].call(funding.name)
          funding.funding_users.where(kind: FundingUser.kind_value(:normal_users)).map {|e| Notification.create(notification_type: Notification.notification_type_project_value, content: content, user_id: e.user_id, is_read: false, notice: {kind: Notification.project_type_value(:after_question), funding_id: self.id})}
      }},
      funding_email: {
      value: 6,
      desc: -> (funding_name) { "【#{funding_name}】项目推送" },
      op: -> {}
      },
      project_advancement: {
        value: 7,
        desc:  -> (funding){"【#{funding}】已完成BSC投票，赞成票+中立票数之和 = 反对票数，待管理员手动推进"},
      },
      funding_ka: {
          value: 8,
          desc: -> (funding){"项目【#{funding}】申请进入KA"},
          op: ->(verification){
            # 把项目变成ka的
            verification.verifyable&.update!(is_ka: true)
          }
      },
      funding_claim: {
          value: 9,
          desc: -> (funding, time) { "认领项目【#{funding}】约见时间（#{time}）" },
          op: -> (verification) {
            funding = verification.verifyable
            funding.duplicate_base_info([verification.sponsor])
          }
      }
  }


  state_config :verifi_type, config: {
    resource: {value: 1, desc: "权限审核"},
    user:     {value: 2, desc: "用户审核"}
  }
end
