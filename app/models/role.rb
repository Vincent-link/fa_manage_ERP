class Role < ApplicationRecord
  has_many :role_resources, dependent: :destroy
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles, source: :user

  validates_presence_of :name
  validates_uniqueness_of :name

  def resource_ids=(*names)
    self.role_resources.delete_all
    names.flatten.each do |name|
      add_resource_by_name name
    end
  end

  def add_resource_by_name resource_name
    self.role_resources.find_or_create_by :name => resource_name
  end

  def user_ids=(*ids)
    self.user_roles.delete_all
    ids.flatten.each do |id|
      add_user_by_id id
    end
  end

  def add_user_by_id id
    self.user_roles.find_or_create_by :user_id => id
  end
end
