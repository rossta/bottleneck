class Ability
  include CanCan::Ability

  def initialize(user)

    can [:update, :read], Project do |project|
      project.has_moderator?(user)
    end

    can :create, Project

  end
end
