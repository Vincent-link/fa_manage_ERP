class User < ApplicationRecord

  attr_accessor :proxier_id

  has_many :investor_groups
  has_many :follows

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
end
