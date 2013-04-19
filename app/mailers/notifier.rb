class Notifier < ActionMailer::Base
  default from: "support@bottleneckapp.herokuapp.com"

  def project_preview_email(project, to_email = nil)
    @project = project
    to_email ||= @project.owner.email
    @preview_token = PreviewToken.new(project)
    mail  to: to_email,
          subject: "Check out your bottlenecks"
  end
end
