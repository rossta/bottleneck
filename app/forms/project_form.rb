class ProjectForm
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  delegate :uid, :name, :time_zone, :persisted?, to: :project, prefix: true

  attribute :uid, String
  attribute :name, String, default: :project_name
  attribute :time_zone, String, default: :default_time_zone

  attr_accessor :moderator

  validates :uid, presence: true
  validates :name, presence: true
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.zones_map(&:name)

  validates :trello_account, presence: true, unless: :project_persisted?

  attr_accessor :project
  attr_accessor :owner, :trello_account

  def initialize(attrs = {})
    yield self if block_given?
    super
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
    @project ||= Project.find_or_initialize_by_uid(uid)
  end

  def project=(project)
    @uid = project.uid
    @project = project
  end

  def default_time_zone
    project_time_zone || 'Eastern Time (US & Canada)'
  end

  private

  def persist!
    project.attributes = attributes
    project.owner = moderator if project.owner.nil? && moderator
    if trello_account
      project.trello_account = trello_account
      project.fetch
    end

    project.save

    project.add_moderator(moderator) if moderator
  end
end
