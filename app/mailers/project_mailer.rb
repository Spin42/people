class ProjectMailer < BaseMailer
  def ending_soon(project)
    @project = project
    to = project.pm.try(:email) || ENV["EMAIL_PM"]
    mail(to: to, subject: "Your project will end soon.", project: @project)
  end

  def three_months_old(project)
    @project = project
    to = project.pm.try(:email) || ENV["EMAIL_PM"], ENV["EMAIL_SOCIAL"]
    mail(to: to, subject: "#{project.name}, references", project: @project)
  end
end
