class User < ApplicationRecord
  scope :user_title_id, -> {where(user_title_id: 2)}

  include RoleExtend
  attr_accessor :proxier_id

  has_one_attached :avatar

  has_many :investor_groups
  has_many :follows
  has_many :user_roles, dependent: :destroy
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

  belongs_to :team, optional: true
  belongs_to :grade, optional: true
  delegate :name, to: :team, :prefix => true, allow_nil: true
  delegate :name, to: :grade, :prefix => true, allow_nil: true

  def position
    ''
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
    verification = Verification.find_by(user_id: self.id, verification_type: "title_update", status: nil)
    @user_title = UserTitle.find(params[:user_title_id])

    if User.current.is_admin?
      User.transaction do
        if !verification.nil?
          if verification.verifi["change"][1] == @user_title.name
            verification.update(status: true)
          else
            verification.update(status: false)
          end
        end
        self.update(params)
      end
    else
      user_title_before = User.current.user_title.name unless User.current.user_title.nil?
      desc = Verification.verification_type_config[:title_update][:desc].call(user_title_before, @user_title.name)
      if !verification.nil?
        verification.update(desc: desc, verifi: {kind: "title_update", change: [user_title_before, @user_title.name]}) unless verification.verifi["change"][1] == @user_title.name
      else
        Verification.create(user_id: User.current.id, sponsor: User.current.id, verification_type: "title_update", desc: desc, verifi: {kind: "title_update", change: [user_title_before, @user_title.name]})
      end

    end
  end

  def is_one_vote_veto?
    roles = Role.includes(:role_resources).where(role_resources: {name: 'admin_one_vote_veto'})
    user_roles = UserRole.select {|e| roles.pluck(:id).include?(e.role_id)}
    true if user_roles.pluck(:user_id).include?(self.id)
  end
end
