class Ability
  include CanCan::Ability

  def initialize(user, options = {})

    can :read, User do |u|
      user == u
    end

    can :update, Project do |project|
      project.has_moderator?(user)
    end

    can :read, Project do |project|
      can?(:update, project) || options[:preview]
    end

    can :create, Project
  end

end
