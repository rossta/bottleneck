class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable
  devise :omniauthable, omniauth_providers: [:trello]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  has_many :owned_projects, class_name: 'Project', foreign_key: :owner_id  # dependent: :destroy
  # has_many :project_memberships
  # has_many :projects, through: :project_memberships

  before_create :ensure_authentication_token

  def projects
    Project.with_role(:moderator, self)
  end

  def find_project(project_id, *args)
    projects.find(project_id)
  end
end
