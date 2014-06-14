class BaseMailer < ActionMailer::Base
  default :from => ENV["EMAIL_FROM"]
end
