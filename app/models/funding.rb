class Funding < ApplicationRecord
  belongs_to :company

  has_many :time_lines
  has_many :funding_company_contacts

  has_many :funding_users

  has_many :evaluations
  has_many :questions

  include StateConfig

  state_config :bsc_status, config: {
      started: {
        value: "started",
        desc: "bsc已启动"
      },
      evaluatting: {
        value: "evaluatting",
        desc: "bsc投票中"
      },
      finished: {
        value: "finished",
        desc: "bsc完成"
      }
  }

  def investment_committee_ids=(*ids)
    self.evaluations.destroy_all
    ids.flatten.each do |id|
      add_investment_committee_by_id id
    end
  end

  def add_investment_committee_by_id id
    self.evaluations.find_or_create_by :user_id => id
  end

  def delete_investment_committee_by_id id
    self.evaluations.find_by(user_id: id).destroy
  end

  def conference_team
    Team.where(id: self.conference_team_ids)
  end

  def is_pass_for_bsc?
    if self.evaluations.count == self.evaluations.where.not(is_agree: nil).count && self.bsc_status == Funding.bsc_status_config[:evaluatting][:value]
      # 找出管理员
      managers = User.select {|e| e.is_admin?}
      # 反对票里面是否存在谁投了一票否决权
      evaluations = self.evaluations.where(is_agree: 'no').select {|e| e.user.is_one_vote_veto?}
      if !evaluations.empty?
        # 项目自动 pass，并给项目成员及管理员发送通知；
        Funding.transaction do
          self.update(status: 9, bsc_status: Funding.bsc_status_config[:evaluatting][:value])
          content = Notification.project_type_config[:passed][:desc].call(self.company.name)
          funding_users = self.funding_users.map {|e| User.find(e.user_id)}

          (managers+funding_users).uniq.map { |e| Notification.create(notification_type: "project", content: content, user_id: e.id) }
        end
      else
        result = self.evaluations.where(is_agree: 'yes').count - self.evaluations.where(is_agree: 'no').count
        case result
        when 0
          # 给项目成员发通知
          content = Notification.project_type_config[:waitting][:desc].call(self.company.name)
          self.funding_users.map {|e| Notification.create(notification_type: "project", content: content, user_id: e.user_id)}

          roles = Role.includes(:role_resources).where(role_resources: {name: 'admin_read_verification'})
          can_verify_users = UserRole.select { |e| roles.pluck(:id).include?(e.role_id) }
          # 给管理员发审核
          desc = Verification.verification_type_config[:bsc_evaluate][:desc].call(self.company.name)
          can_verify_users.pluck(:user_id).map {|e| Verification.create(verification_type: "bsc_evaluate", desc: desc, user_id: e.user_id, verifi: {funding_id: self.id})} unless can_verify_users.nil?
        when -Float::INFINITY...0
          # 项目自动 pass，并给项目成员及管理员发送通知；
          Funding.transaction do
            self.update(status: 9, bsc_status: Funding.bsc_status_config[:evaluatting][:value])
            content = Notification.project_type_config[:passed][:desc].call(self.company.name)
            funding_users = self.funding_users.map {|e| User.find(e.user_id)}

            (managers+funding_users).uniq.map { |e| Notification.create(notification_type: "project", content: content, user_id: e.id) }
          end
        when 0..Float::INFINITY
          # 项目自动推进到Pursue，并给项目成员及管理员发送通知；
          Funding.transaction do
            self.update(status: 3, bsc_status: Funding.bsc_status_config[:evaluatting][:value])
            content = Notification.project_type_config[:pursued][:desc].call(self.company.name)
            funding_users = self.funding_users.map {|e| User.find(e.user_id)}

            (managers+funding_users).uniq.map { |e| Notification.create(notification_type: "project", content: content, user_id: e.id) }
          end
        end
      end
    end
  end
end
