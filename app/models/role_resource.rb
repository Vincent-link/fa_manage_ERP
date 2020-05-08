class RoleResource < ApplicationRecord
  belongs_to :role

  after_destroy :destroy_children

  def resource
    Resource.find_by_name self.resource_name
  end

  def destroy_children
    res = Resource.find_by_name self.resource_name
  end
end
