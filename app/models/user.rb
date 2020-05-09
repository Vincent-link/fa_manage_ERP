class User < ApplicationRecord
  include RoleExtend
  attr_accessor :proxier_id

  has_many :investor_groups
  has_many :follows
  has_many :user_roles, dependent: :destroy

  def self.find_or_create_user(auth_user_hash)
    self.find_or_create_by(:id => auth_user_hash.id) do |user|
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

  def add_role_by_id id
    self.user_roles.with_deleted.find_or_create_by :role_id => id
  end
end
