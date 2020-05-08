class Role < ApplicationRecord
  has_many :role_resources, dependent: :destroy
  has_and_belongs_to_many :users, :join_table => :users_roles

  validates_presence_of :name
  validates_uniqueness_of :name

  def resource_ids=(*names)
    self.role_resources.delete_all
    names.flatten.each do |name|
      add_resource_by_name name
    end
  end

  def add_resource resource
    add_resource_by_name resource.name
  end

  def add_resource_by_name resource_name
    self.role_resources.find_or_create_by :resource_name => resource_name
  end

  def resources
    chosen_resource_name = self.role_resources.pluck(:resource_name)
    Resource.resources.find_all do |res|
      chosen_resource_name.include?(res.name)
    end
  end
end
