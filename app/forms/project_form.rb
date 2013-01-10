class ProjectForm
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :uid, String, default: :project_uid
  attribute :name, String, default: :project_name

  validates :uid, presence: true
  validates :name, presence: true
  validates :owner, presence: true, unless: :project_persisted?
  validates :trello_account, presence: true, unless: :project_persisted?

  delegate :uid, :name, :persisted?, to: :project, prefix: true

  attr_accessor :project
  attr_accessor :owner, :trello_account

  def initialize(attrs = {})
    super
    yield self if block_given?
  end

  def persisted?
    false
  end

  def save
    if valid?
      persist!
      true
    else
      project.errors.add(:base, "There was a problem with the import. Please try again.")
      false
    end
  end

  def project
    @project ||= Project.new
  end

  private

  def persist!
    project.attributes = attributes
    project.owner = owner if owner

    if trello_account
      project.trello_account
      project.fetch
    end

    project.save

    project.add_moderator(owner) if owner
  end
end
