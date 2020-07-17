class Funding < FundingPolymer
  include BlobFileSupport

  has_many_attached :file_materials
  has_one_attached :file_teaser
  has_one_attached :file_bp
  has_one_attached :file_nda
  has_one_attached :file_model
  has_one_attached :file_el

  has_blob_upload :file_teaser, :file_bp, :file_nda, :file_model, :file_el
  have_blob_upload :file_materials

  belongs_to :funding_source_member, class_name: 'Member', foreign_key: :source_member, optional: true

  has_many :funding_company_contacts, class_name: 'FundingCompanyContact'

  has_many :calendars

  has_many :track_logs
  has_many :spas, -> {where(:status => TrackLog.status_spa_sha_value)}, class_name: 'TrackLog'

  has_many :emails, as: :emailable

  has_many :evaluations
  has_many :questions

  has_many :users, through: :funding_users

  before_create :gen_serial_number
  after_create :base_time_line
  after_create :reviewing_status
  after_save :gen_time_line

  delegate :sector_list, to: :company

  def gen_serial_number
    current_year = Time.now.year
    pre_index = Funding.with_deleted.where("created_at > ?", Time.new(current_year))
                    .order(:serial_number => :desc).first
                    .serial_number&.slice(-6..-1).to_i || 0 rescue 0
    self.serial_number = "E#{current_year.to_s.slice(-2..-1)}#{format('%06d', pre_index + 1)}"
  end

  def reviewing_status
    self.update(status: Funding.status_reviewing_value)
  end

  def base_time_line
    self.time_lines.create(status: self.status, user_id: User.current.id)
  end

  def gen_time_line
    if saved_change_to_attribute?(:status)
      self.time_lines.create(status: self.status, user_id: User.current.id)
    end
  end

  def user_names
    self.users.map(&:name).join('、')
  end

  def add_project_follower(params)
    if params[:normal_user_ids].present?
      self.funding_normal_users.where.not(user_id: params[:normal_user_ids]).destroy_all
      (params[:normal_user_ids] - self.normal_user_ids).each do |user_id|
        self.funding_normal_users.create(kind: FundingUser.kind_normal_users_value, user_id: user_id)
      end
    end

    if params[:bd_leader_id].present?
      if self.bd_leader.present?
        self.funding_bd_leader.first.update(user_id: params[:bd_leader_id])
      else
        self.funding_bd_leader.create(kind: FundingUser.kind_bd_leader_value, user_id: params[:bd_leader_id])
      end
    else
      self.funding_bd_leader_ids = []
    end

    if params[:execution_leader_id].present?
      if self.execution_leader.present?
        self.funding_execution_leader.first.update(user_id: params[:execution_leader_id])
      else
        self.funding_execution_leader.create(kind: FundingUser.kind_execution_leader_value, user_id: params[:execution_leader_id])
      end
    else
      self.funding_execution_leader_ids = []
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
    [:file_materials, :file_bp, :file_el, :file_model, :file_nda, :file_teaser].each do |attr|
      self.try("#{attr.to_s}_file=", params[attr]) if params[attr].present?
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
      raise '未传el' unless self.file_el_atttachment.present?
      raise '未填收入预测' unless self.pipelines.present?
    when Funding.status_closing_value
      raise '未传spa' unless ActiveStorage::Attachment.where(name: 'file_ts', record_type: 'TrackLog', record_id: self.track_log_ids).present?
    when Funding.status_closed_value
      raise '未传spa' unless ActiveStorage::Attachment.where(name: 'file_spa', record_type: 'TrackLog', record_id: self.track_log_ids).present?
    when Funding.status_paid_value
      raise '未提交财务确认收款' unless self.pipelines.status_fee_ed.present?
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
    if self.evaluations.count == self.evaluations.where.not(is_agree: nil).count && self.bsc_status == Funding.bsc_status_evaluatting_value
      # 找出管理员
      managers = User.select {|e| e.is_admin?}
      # 反对票里面是否存在谁投了一票否决权
      evaluations = self.evaluations.where(is_agree: 'no').select {|e| e.user.is_one_vote_veto?}
      if !evaluations.empty?
        # 项目自动 pass，并给项目成员及管理员发送通知；
        Funding.transaction do
          self.update!(status: Funding.status_pass_value, bsc_status: Funding.bsc_status_evaluatting_value)
          content = Notification.project_type_passed_desc.call(self.company.name)
          funding_users = self.funding_users.map {|e| User.find(e.user_id)}

          (managers + funding_users).uniq.map {|e| Notification.create!(notification_type: Notification.notification_type_project_value, content: content, user_id: e.id, is_read: false, notice: {funding_id: self.id})}
        end
      else
        result = self.evaluations.where(is_agree: 'yes').count - self.evaluations.where(is_agree: 'no').count
        case result
        when 0
          self.update!(status: Funding.status_pass_value, bsc_status: Funding.bsc_status_finished_value)
          # 给项目成员发通知
          content = Notification.project_type_waitting_desc.call(self.company.name)
          self.funding_users.map {|e| Notification.create!(notification_type: Notification.notification_type_project_value, content: content, user_id: e.user_id, is_read: false, notice: {funding_id: self.id})}
          # 给管理员发审核
          desc = Verification.verification_type_project_advancement_desc.call(self.company.name)
          verification = Verification.find_by(verification_type: Verification.verification_type_project_advancement_value, verifi: {funding_id: self.id}, verifi_type: Verification.verifi_type_resource_value)
          if verification.nil?
            Verification.create!(verification_type: Verification.verification_type_project_advancement_value, desc: desc, verifi: {funding_id: self.id, funding_name: self.name, round_id: self.round_id, user_id: User.current.id}, verifi_type: Verification.verifi_type_resource_value)
          end
        when -Float::INFINITY...0
          # 项目自动 pass，并给项目成员及管理员发送通知；
          Funding.transaction do
            self.update!(status: Funding.status_pass_value, bsc_status: Funding.bsc_status_finished_value)
            content = Notification.project_type_passed_desc.call(self.company.name)
            funding_users = self.funding_users.map {|e| User.find(e.user_id)}

            (managers + funding_users).uniq.map {|e| Notification.create!(notification_type: Notification.notification_type_project_value, content: content, user_id: e.id, is_read: false, notice: {funding_id: self.id})}
          end
        when 0..Float::INFINITY
          # 项目自动推进到Pursue，并给项目成员及管理员发送通知；
          Funding.transaction do
            self.update!(status: Funding.status_pursue_value, bsc_status: Funding.bsc_status_finished_value, agree_time: Time.now)
            content = Notification.project_type_pursued_desc.call(self.company.name)
            funding_users = self.funding_users.map {|e| User.find(e.user_id)}

            (managers + funding_users).uniq.map {|e| Notification.create!(notification_type: Notification.notification_type_project_value, content: content, user_id: e.id, is_read: false, notice: {funding_id: self.id})}
          end
        end
      end
    end
  end

  def change_spas(user_id, params)
    spas = self.spas
    params[:spas].each do |spa|
      case spa[:action]
      when 'delete'
        spa_track_log = spas.find(spa[:id])
        spa_track_log.destroy
      when 'update'
        spa_track_log = spas.find(spa[:id])
        [:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio, :currency].each {|ins| raise '融资结算信息不全' unless (spa[ins] || spa_track_log.try(ins.to_s)).present?}
        spa_track_log.update!(spa.slice(:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio, :currency))
        if spa[:file_spa][:blob_id].present?
          spa_track_log.file_spa_file=spa[:file_spa]
        end
      when 'create'
        if spa[:id].present?
          spa_track_log = self.track_logs.find(spa[:id])
          [:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio, :currency].each {|ins| raise '融资结算信息不全' unless (spa[ins] || spa_track_log.try(ins.to_s)).present?}
          raise 'SPA文件必传' unless spa[:file_spa][:blob_id].present? || spa_track_log.file_spa.present?
          spa_track_log.update!(spa.slice(:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio, :currency).merge(status: TrackLog.status_spa_sha_value))
          if spa[:file_spa][:blob_id].present?
            spa_track_log.file_spa_file=spa[:file_spa]
          end
        else
          [:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio, :currency, :organization_id].each {|ins| raise '融资结算信息不全' unless spa[ins].present?}
          raise 'SPA文件必传' unless spa[:file_spa][:blob_id].present?
          spa_track_log = self.spas.create(spa.slice(:pay_date, :is_fee, :fee_discount, :fee_rate, :amount, :ratio, :currency, :organization_id))
          spa_track_log.member_ids = Organization.find(spa[:organization_id]).members.where(id: spa[:member_ids]).map(&:id)
          spa_track_log.file_spa_file=spa[:file_spa]
        end
      end
      spa_track_log.gen_spa_detail(user_id, spa[:action])
    end
  end

  def is_pass?
    is_pass = ""
    if self.bsc_status == "finished"
      result = self.evaluations.where(is_agree: 'yes').count - self.evaluations.where(is_agree: 'no').count
      case result
      when 0
        is_pass = "待决策"
      when -Float::INFINITY...0
        is_pass = "passed"
      when 0..Float::INFINITY
        is_pass = "pursued"
      end
    end
    is_pass
  end

  def round
    round_arr = CacheBox::dm_rounds.select { |e| e["id"] == self.round_id }
    round_name = ""
    round_name = round_arr.first["name"] unless round_arr.empty?
    round_name
  end

  def is_list?
    if self.is_list.nil?
      is_list = self.is_list
    else
      is_list = self.is_list ? "是" : "否"
    end
  end

  def gen_ka_verification
    raise '不能重复提交审核' if self.verifications.verification_type_funding_ka.where(status: nil).present?
    desc = Verification.verification_type_config[:funding_ka][:desc].call(self.name)
    self.verifications.create(verification_type: Verification.verification_type_funding_ka_value, desc: desc, sponsor: User.current.id, verifi_type: Verification.verifi_type_resource_value)
  end

  def export_track_log(params)
    track_logs = self.track_logs.includes(:organization, :members, :track_log_details).search(params)

    file_name = "#{self.name} TrackLog-#{Time.now.strftime("%Y-%m-%d").to_s}"
    file_path = "#{Rails.root}/public/export/#{file_name + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + '.xls'}"
    title = [%w(项目名称 投资机构 投资人 状态 已发送文档 最新更新时间 跟进记录 备注)]
    currency = CacheBox.dm_currencies.map{|ins| [ins['id'], ins['name']]}.to_h

    res = {}
    TrackLog.status_values.each{|ins| res[ins] = title}

    track_logs.each do |track_log|
      track_log_detail_contents = track_log.track_log_details.map do |track_log_detail|
        case
        when track_log_detail.detail_type_spa?
          "#{track_log_detail.created_at.strftime("%Y-%m-%d").to_s}#{track_log_detail.content} (投资#{track_log_detail.history[:amount]}万#{currency[track_log_detail.history[:currency]]},占股#{track_log_detail.history[:ratio]}%)"
        when track_log_detail.detail_type_calendar?
          "#{track_log_detail.created_at.strftime("%Y-%m-%d").to_s}#{track_log_detail.content}，时间：#{track_log_detail.history[:started_at]}-#{track_log_detail.history[:ended_at]},地点：#{track_log_detail.history[:address_desc]}"
        else
          "#{track_log_detail.created_at.strftime("%Y-%m-%d").to_s}#{track_log_detail.content}"
        end
      end

      res[track_log.status] << [
          self.name,
          track_log.organization&.name,
          track_log.members&.map(&:name).join('、'),
          track_log.status_desc,
          [(track_log.has_nda ? 'NDA' : nil), (track_log.has_bp ? 'BP' : nil), (track_log.has_teaser ? 'TEASER' : nil), (track_log.has_model ? 'MODEL' : nil)].compact.join('、'),
          track_log.track_log_details.first.created_at.strftime("%Y-%m-%d").to_s,
          track_log_detail_contents.compact.join('\n'),
          ''
      ]
    end
    book_data = []
    TrackLog.status_id_name.each do |ins|
      book_data << [ins[:name], res[ins[:id]]]
    end
    Common::ExcelGenerator.gen(file_path, book_data)
    [file_path, file_name]
  end

  def gen_claim_verification(params)
    raise '不能重复提交审核' if self.verifications.verification_type_funding_claim.where(status: nil).present?
    params[:company_id] = self.company_id
    calendar = User.current.created_calendars.create!(params)
    desc = Verification.verification_type_config[:funding_claim][:desc].call(self.name, calendar.started_at.strftime("%Y年%m月%日 %H:%M"))
    self.verifications.create(verification_type: Verification.verification_type_funding_claim_value, desc: desc, sponsor: User.current.id, verifi_type: Verification.verifi_type_resource_value)
  end

  def duplicate_base_info(normal_user_ids)
    attributes = ['company_id', 'category', 'round_id', 'name',

                  'com_desc', 'products_and_business', 'financial',
                  'operational', 'market_competition', 'financing_plan',
                  'other_desc',

                  'shiny_word', 'source_type', 'source_member',
                  'source_detail', 'funding_score', 'target_amount_currency',
                  'is_complicated', 'target_amount', 'share',
                  'post_investment_valuation', 'post_valuation_currency',
                  'type', 'other_funding_id', 'other_funding_type', 'category_name']
    funding_params = self.slice(attributes)
    funding_params['is_ka'] = self.company.is_ka
    funding_params['operating_day'] = Date.today
    funding = Funding.create!(funding_params)
    funding.add_project_follower(normal_user_ids: normal_user_ids)
    funding
  end
end
