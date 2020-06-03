class Funding < ApplicationRecord
  acts_as_paranoid
  # searchkick

  include ModelState::FundingState

  has_many_attached :funding_materials
  has_one_attached :funding_teaser
  has_one_attached :funding_bp
  has_one_attached :funding_nda
  has_one_attached :funding_model
  has_one_attached :funding_el

  belongs_to :company
  belongs_to :funding_source_member, class_name: 'Member', foreign_key: :source_member

  has_many :time_lines, -> { order(created_at: :desc) }, class_name: 'TimeLine'
  has_many :funding_company_contacts, class_name: 'FundingCompanyContact'

  has_many :funding_project_users, -> { kind_funding_project_users }, class_name: 'FundingUser'
  has_many :project_users, through: :funding_project_users, source: :user

  has_many :funding_bd_leader, -> { kind_bd_leader }, class_name: 'FundingUser'
  has_many :bd_leader, through: :funding_bd_leader, source: :user

  has_many :funding_execution_leader, -> { kind_execution_leader }, class_name: 'FundingUser'
  has_many :execution_leader, through: :funding_execution_leader, source: :user

  has_many :calendars

  before_create :gen_serial_number
  after_create :base_time_line

  def gen_serial_number
    current_year = Time.now.year
    pre_index = Funding.with_deleted.where("created_at > ?", Time.new(current_year))
                    .order(:serial_number => :desc).first
                    .serial_number&.slice(-6..-1).to_i || 0 rescue 0
    self.serial_number = "E#{current_year.to_s.slice(-2..-1)}#{format('%06d', pre_index+1)}"
  end

  def base_time_line
    self.time_lines.create(status: self.status)
  end

  def search_data
    # attributes.merge company_name: self.company&.name,
    #                  company_sector_names: self.company&.sector_ids.map { |ins| CacheBox.dm_single_sector_tree[ins] },
    #                  sector_ids: self.company&.sector_ids
    # todo 约见
    # todo Tracklog
  end

  def self.es_search(params)
    where_hash = {}
    where_hash[:sector_ids] = {all: params[:sector]} if params[:sector].present?
    where_hash[:round_ids] = {all: params[:round]} if !params[:any_round] && params[:round].present?
    where_hash[:location_ids] = {all: params[:round]} if !params[:any_round] && params[:round].present?
    # todo 搜索还没好
    Funding.all.limit 10
  end

  def add_project_follower(params)
    if params[:project_user_ids].present?
      self.project_user_ids = params[:project_users_ids]
    end

    if params[:bd_leader_id].present?
      self.bd_leader_ids = [params[:bd_leader_id]]
    end

    if params[:execution_leader_id].present?
      self.execution_leader_ids = [params[:execution_leader_id]]
    end
  end

  def gen_funding_company_contacts(params)
    if params[:funding_company_contacts].present?
      params[:funding_company_contacts].each do |fudning_company_contact|
        self.gen_funding_company_contact(fudning_company_contact.slice(:name, :position_id, :email,
                                                                       :mobile, :wechat, :is_attend,
                                                                       :is_open, :description))
      end
    end
  end

  def gen_funding_company_contact(params)
    self.funding_company_contacts.create(params.slice(:name, :position_id, :email,
                                                      :mobile, :wechat, :is_attend,
                                                      :is_open, :description))
  end

  def funding_various_file(params)
    if params[:attachments].present? || params[:attachment_ids].present?
      self.funding_materials.each do |funding_material|
        unless params[:attachment_ids].map { |ins| ins.to_i }.include? funding_material.id
          funding_material.purge
        end
      end
      params[:attachments].each do |attachment|
        self.funding_materials.attach ActionDispatch::Http::UploadedFile.new(attachment)
      end
    end
    if params[:teaser].present?
      self.funding_teaser = ActionDispatch::Http::UploadedFile.new(params[:teaser])
    end
    if params[:bp].present?
      self.funding_bp = ActionDispatch::Http::UploadedFile.new(params[:bp])
    end
    if params[:nda].present?
      self.funding_nda = ActionDispatch::Http::UploadedFile.new(params[:nda])
    end
    if params[:model].present?
      self.funding_model = ActionDispatch::Http::UploadedFile.new(params[:model])
    end
    if params[:el].present?
      self.funding_el = ActionDispatch::Http::UploadedFile.new(params[:el])
    end
  end

  def funding_status_auth(status, go_to, params)
    self.auth_status(status, go_to)
    self.auth_data(go_to, params)
  end

  def auth_data(go_to, params)
    case go_to
    when Funding.status_voting_value
      if ActiveModel::Type::Boolean.new.cast params[:is_list]
        raise '未传股票信息' unless params[:ticker].present?
      end
      raise '公司简介不少于400字' if params[:com_desc].size < 400
    when Funding.status_execution_value
      # todo 判断是否上传EL
      # todo 判断是否有收入预测（李靖超）
    when Funding.status_closing_value
      # todo 判断是否有TS tracklog
      # todo 判断是否有TS状态换过的 tracklog
    when Funding.status_closed_value
      # todo 判断是否有SPA tracklog
    when Funding.status_paid_value
      # todo 判断是否提交财务确认收款（李靖超）
    end
  end

  def auth_status(status, go_to)
    if !([Funding.status_hold_value, Funding.status_pass_value].include? go_to) && !([Funding.status_hold_value, Funding.status_pass_value].include? status) && self.status != status
      raise "项目不是#{Funding.status_desc_for_value(status)}阶段不能移动到#{Funding.status_desc_for_value(go_to)}阶段"
    end

    raise '操作重复' if status == go_to

    case go_to
    when Funding.status_pass_value
      no_pass = [Funding.status_execution_value, Funding.status_closing_value, Funding.status_closed_value, Funding.status_paid_value]
      if no_pass.include? self.status
        raise "#{Funding.status_desc_for_value(self.status)}阶段不能移动到#{Funding.status_desc_for_value(Funding.status_pass_value)}阶段"
      end
    when Funding.status_hold_value
      no_hold = [Funding.status_reviewing_value, Funding.status_interesting_value, Funding.status_voting_value, Funding.status_closed_value, Funding.status_paid_value]
      if no_hold.include? self.status
        raise "#{Funding.status_desc_for_value(self.status)}阶段不能移动到#{Funding.status_desc_for_value(Funding.status_hold_value)}阶段"
      end
    end

    case self.status
    when Funding.status_pass_value
      # todo 认领还需要审批那块（柳辉）
    when Funding.status_hold_value
      can_move = [Funding.status_pass_value, self.time_lines.last(2).first.status]
      unless can_move.include? go_to
        raise "只能移动到#{Funding.status_desc_for_value(Funding.status_pass_value)}阶段或#{Funding.status_desc_for_value(self.time_lines.last(2).first.status)}阶段"
      end
    end
  end

  has_many :funding_users

  has_many :evaluations
  has_many :questions



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
          self.update(status: Funding.status_pass_value, bsc_status: Funding.bsc_status_config[:evaluatting][:value])
          content = Notification.project_type_config[:passed][:desc].call(self.company.name)
          funding_users = self.funding_users.map {|e| User.find(e.user_id)}

          (managers+funding_users).uniq.map { |e| Notification.create(notification_type: "project", content: content, user_id: e.id, is_read: false) }
        end
      else
        result = self.evaluations.where(is_agree: 'yes').count - self.evaluations.where(is_agree: 'no').count
        case result
        when 0
          # 给项目成员发通知
          content = Notification.project_type_config[:waitting][:desc].call(self.company.name)
          self.funding_users.map {|e| Notification.create(notification_type: "project", content: content, user_id: e.user_id, is_read: false)}

          roles = Role.includes(:role_resources).where(role_resources: {name: 'admin_read_verification'})
          can_verify_users = UserRole.select { |e| roles.pluck(:id).include?(e.role_id) }
          # 给管理员发审核
          desc = Verification.verification_type_config[:bsc_evaluate][:desc].call(self.company.name)
          can_verify_users.pluck(:user_id).map {|e| Verification.create(verification_type: "bsc_evaluate", desc: desc, user_id: e.user_id, verifi: {funding_id: self.id})} unless can_verify_users.nil?
        when -Float::INFINITY...0
          # 项目自动 pass，并给项目成员及管理员发送通知；
          Funding.transaction do
            self.update(status: Funding.status_pass_value, bsc_status: Funding.bsc_status_config[:evaluatting][:value])
            content = Notification.project_type_config[:passed][:desc].call(self.company.name)
            funding_users = self.funding_users.map {|e| User.find(e.user_id)}

            (managers+funding_users).uniq.map { |e| Notification.create(notification_type: "project", content: content, user_id: e.id, is_read: false) }
          end
        when 0..Float::INFINITY
          # 项目自动推进到Pursue，并给项目成员及管理员发送通知；
          Funding.transaction do
            self.update(status: Funding.status_pursue_value, bsc_status: Funding.bsc_status_config[:evaluatting][:value])
            content = Notification.project_type_config[:pursued][:desc].call(self.company.name)
            funding_users = self.funding_users.map {|e| User.find(e.user_id)}

            (managers+funding_users).uniq.map { |e| Notification.create(notification_type: "project", content: content, user_id: e.id, is_read: false) }
          end
        end
      end
    end
  end
end
