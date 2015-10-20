class UserMailer < ActionMailer::Base
  default :from => "rares.dragus@softvision.ro"

  def following_confirmation(user, current_user)
    @user = user
    @current_user = current_user
    mail(:to => "#{user.name} <#{user.email}>", :subject => "Registered")
  end
end
