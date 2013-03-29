class AnonymousUser
  def persisted?; false; end
  def has_role?(*args); false; end
  def name; 'Visitor'; end

  def find_project(project_id, preview_token)
    Project.find(project_id).tap do |project|
      raise ActiveRecord::RecordNotFound if PreviewToken.new(project) != preview_token
    end
  end
end
