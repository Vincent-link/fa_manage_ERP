class User < ApplicationRecord
  acts_as_paranoid
  scope :user_title_id, -> {where(user_title_id: 2)}

  include RoleExtend
  include BlobFileSupport
  attr_accessor :proxier_id

  has_one_attached :avatar
  has_blob_upload :avatar

  after_validation :set_bu_id

  has_many :investor_groups
  has_many :follows
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :evaluations, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :verifications, dependent: :destroy, as: :verifyable
  has_many :questions, dependent: :destroy
  belongs_to :user_title, optional: true
  has_many :calendar_members, as: :memberable
  has_many :calendars, through: :calendar_members
  has_many :created_calendars, foreign_key: :user_id, class_name: 'Calendar'
  belongs_to :leader, class_name: 'User', optional: true
  has_many :sub_users, class_name: 'User', foreign_key: :leader_id
  has_many :sub_user_calendars, through: :sub_users, source: :calendars
  has_many :group_calendars, through: :group_users, source: :calendars
  has_many :group_users, -> {where(id: CacheBox.get_group_user_ids(self.id))}, class_name: 'User'

  has_many :email_receivers, as: :receiverable
  has_many :email_tos, as: :toable

  belongs_to :team, optional: true
  belongs_to :bu, optional: true, class_name: 'Team', foreign_key: :bu_id
  belongs_to :grade, optional: true
  delegate :name, to: :team, :prefix => true, allow_nil: true
  delegate :name, to: :bu, :prefix => true, allow_nil: true
  delegate :name, to: :grade, :prefix => true, allow_nil: true

  belongs_to :kpi_group, optional: true

  def position
    '' #todo
  end

  def self.find_or_create_user(auth_user_hash)
    auth_user_hash = Hashie::Mash.new auth_user_hash
    self.find_or_create_by!(:id => auth_user_hash.id) do |user|
      user.name = auth_user_hash.name
      user.email = auth_user_hash.email
      user.team_id = auth_user_hash.team_id
      user.grade_id = auth_user_hash.grade_id
    end
  end

  def self.current
    Thread.current[:current_user]
  end

  def self.current=(user)
    Thread.current[:current_user] = user
    Thread.current[:current_ability] = nil if user == nil
  end

  def self.current_ability
    Thread.current[:current_ability] ||= Ability.new(self.current) if self.current
  end

  def self.sso_column
    :id
  end

  def role_ids=(*ids)
    self.user_roles.delete_all
    ids.flatten.each do |id|
      add_role_by_id id
    end
  end

  def is_current_bu
    self.bu_id == Settings.current_bu_id
  end

  # def group_users
  #   User.where(id: CacheBox.get_group_user_ids(self.id))
  # end

  def add_role_by_id id
    self.user_roles.find_or_create_by :role_id => id
  end

  def delete_role_by_id id
    self.user_roles.find_by(role_id: id).destroy
  end

  def is_admin?
    roles = Role.includes(:role_resources).where(role_resources: {name: 'admin_manage_all'})
    can_verify_users = UserRole.select {|e| roles.pluck(:id).include?(e.role_id)}
    true if can_verify_users != nil && can_verify_users.pluck(:user_id).include?(self.id)
  end

  def update_title(params)
    verification = Verification.find_by(user_id: self.id, verification_type: Verification.verification_type_title_update_value, status: nil, verifi_type: Verification.verifi_type_resource_value)
    @user_title = UserTitle.find(params[:user_title_id])

    if User.current.is_admin?
      User.transaction do
        if !verification.nil?
          if verification.verifi["change"][1] == @user_title.name
            verification.update!(status: true)
          else
            verification.update!(status: false)
          end
        end
        self.update!(params)
      end
    else
      user_title_before = User.current.user_title.name unless User.current.user_title.nil?
      desc = Verification.verification_type_title_update_desc.call(user_title_before, @user_title.name)
      if !verification.nil?
        verification.update(desc: desc, verifi: {kind: Verification.verification_type_title_update_value, change: [user_title_before, @user_title.name]}) unless verification.verifi["change"][1] == @user_title.name
      else
        Verification.create(user_id: User.current.id, sponsor: User.current.id, verification_type: Verification.verification_type_title_update_value, desc: desc, verifi: {kind: "title_update", change: [user_title_before, @user_title.name]}, verifi_type: Verification.verifi_type_resource_value)
      end

    end
  end

  def is_one_vote_veto?
    roles = Role.includes(:role_resources).where(role_resources: {name: 'admin_one_vote_veto'})
    user_roles = UserRole.select {|e| roles.pluck(:id).include?(e.role_id)}
    true if user_roles.pluck(:user_id).include?(self.id)
  end

  def email_password
    return nil unless encrypted_email_password
    begin
      len = ActiveSupport::MessageEncryptor.key_len
      key = ActiveSupport::KeyGenerator.new('password').generate_key(Rails.application.credentials.secret_key_base, len)
      crypt = ActiveSupport::MessageEncryptor.new(key)
      crypt.decrypt_and_verify(encrypted_email_password)
    rescue Exception => e
      Rails.logger.error(e)
      return nil
    end
  end

  def update_email_password(new_password)
    len = ActiveSupport::MessageEncryptor.key_len
    key = ActiveSupport::KeyGenerator.new('password').generate_key(Rails.application.credentials.secret_key_base, len)
    crypt = ActiveSupport::MessageEncryptor.new(key)
    self.update(encrypted_email_password: crypt.encrypt_and_sign(new_password))
  end

  def valid_email_password?(email_password = self.email_password)
    server = email.to_s.strip.downcase.match(/chinarenaissance.com$/) ? Settings.smtp_intel.server : Settings.smtp.server
    port, domain = Settings.smtp.port, Settings.smtp.domain
    smtp = Net::SMTP.new(server, port)
    smtp.enable_starttls_auto
    begin
      smtp.start(domain, self.email, email_password, :login) do |_smtp|
        self.update_email_password(email_password)
        return true
      end
    rescue Exception => e
      Rails.logger.error(e)
      return false
    end
  end

  def statis_kpi_titles(year)
    arr = []
    titles = kpi_types(year)

    arr.unshift({"member_name": "成员名称"})
    titles.pluck(:id, :kpi_type).uniq.map { |title|
      row = {}
      # 如果kpi没有条件，显示自己的desc和描述，如果有条件，显示条件的statis_title和描述
      row[title[1]] = Kpi.kpi_type_desc_for_value(title[1])
      row[title[1]] = Kpi.find(title[0]).conditions.last.statis_title if !Kpi.find(title[0]).conditions.empty?
      row["kpi描述"] = Kpi.kpi_type_config_for_value(title[1])[:remarks]
      row["kpi描述"] = Kpi.kpi_type_config_for_value(Kpi.find(title[0]).conditions.last.kpi_type)[:remarks] if !Kpi.find(title[0]).conditions.empty?

      if !arr.map(&:keys).include?([title[1], "kpi描述"])
        arr << row
      end
    }
    arr.append({"member_id": "成员id"})
  end

  def statis_kpi_data(year)
    arr = []
    (self.sub_users.append(self)).joins(:kpi_group).map {|user|
      row = {}

      new_row = {"member_name": user.name}.merge(row)
      user.kpi_group.kpis.where("extract(year from kpis.created_at)  = ?", year).map {|kpi|
        kpi_types(year).pluck(:kpi_type).uniq.map{|type|
            if kpi.kpi_type == type
              # 如果kpi配置存有条件
              conditions = kpi.conditions.map{|e| " #{e.relation} #{Kpi.kpi_type_config_for_value(e.kpi_type)[:action]}#{Kpi.kpi_type_op_for_value(e.kpi_type).call(user.id, e.coverage, year)}#{Kpi.kpi_type_config_for_value(e.kpi_type)[:unit]}/#{e.value}#{Kpi.kpi_type_config_for_value(e.kpi_type)[:unit]}"}.join(" ") unless kpi.conditions.empty?

              new_row["#{type}"] = "不在系统中统计"

              new_row["#{type}"] = "#{Kpi.kpi_type_config_for_value(kpi.kpi_type)[:action]}#{Kpi.kpi_type_op_for_value(type).call(user.id, kpi.coverage, year)}#{Kpi.kpi_type_config_for_value(kpi.kpi_type)[:unit]}/#{kpi.value}#{Kpi.kpi_type_config_for_value(kpi.kpi_type)[:unit]}#{conditions}" if Kpi.kpi_type_config_for_value(kpi.kpi_type)[:is_system]
            end
        }
      }
      new_row = new_row.merge({"member_id": user.id})

      arr << new_row
    }
    arr
  end

  def kpi_types(year)
    (self.sub_users.append(self)).map(&:kpi_group).compact.uniq.map{|e| e.kpis.where("extract(year from kpis.created_at)  = ?", year).where(parent_id: nil)}.flatten
  end

  def set_bu_id
    if self.team_id_changed?
      current_team = self.team
      while current_team
        if current_team.level == 2
          self.bu_id = current_team.id
          break
        else
          current_team = current_team.parent_team
        end
      end
    end
  end

end
