class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, User do |u|
      user == u
    end

    can [:update, :read], Project do |project|
      project.has_moderator?(user)
    end

    can :create, Project

  end
end
