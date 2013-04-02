class Notifier < ActionMailer::Base
  default from: "support@bottleneckapp.herokuapp.com"

  def project_preview_email(project)
    @project = project
    @preview_token = PreviewToken.new(project)
    mail  to: @project.owner.email,
          subject: "Check out your bottlenecks"
  end
end
