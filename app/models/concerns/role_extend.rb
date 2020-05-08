module RoleExtend
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :roles, :join_table => :users_roles
    has_many :role_resources, :through => :roles

    def has_role? role
      self.roles.include? role
    end

    def add_role role
      role = Role.find(role) if role.is_a? Integer
      self.roles << role
    end

    def remove_role role
      self.roles.delete(role)
    end

    def all_role_resources
      res = self.role_resources.pluck(:resource_name).uniq
      child_res = []
      res.each do |ins|
        if ins.split('_').first == 'manage'
          r = Resource.find_by_name ins
          if r.object.to_s == 'all'
            return Resource.resources.map &:name
          else
            child_res = child_res | Resource.object_group[r.object].map(&:name)
          end
        end
      end
      (res | child_res).uniq
    end
  end
end
