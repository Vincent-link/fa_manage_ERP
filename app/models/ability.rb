# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # resource role
    @user = user
    user.user_roles.each do |user_role|
      user_role.role.role_resources.each do |role_resource|
        resource = Resource.find_by_name(role_resource.name)
        #Todo clear role_resource when resource not exist
        Rails.logger.error "Error: Resource [#{role_resource.name}] not found" and next if resource.nil?
        if resource.block
          instance_eval &(resource.block)
        end
      end
    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
