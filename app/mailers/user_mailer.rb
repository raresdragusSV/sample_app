class UserMailer < ActionMailer::Base
  default :from => "rares.dragus@softvision.ro"

  def following_confirmation(user, current_user)
    @user = user
    @current_user = current_user
    mail(:to => "#{user.name} <#{user.email}>", :subject => "Registered")
  end

  def password_reset(user)
    @user = user
    mail(:to => "#{@user.name} <#{@user.email}>", :subject => 'Password Reset')
  end

  def signup_confirmation(user)
    @user = user
    @confirmation_uri = "http://localhost:3000#{confirm_user_path(@user.remember_token)}"
    mail(:to => "#{@user.name} <#{@user.email}>", :subject => 'Confirmation Account')
  end
end
