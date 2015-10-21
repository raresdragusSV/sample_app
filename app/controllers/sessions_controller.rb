class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.state == 'inactive'
        flash[:error] = "Your account isn't confirmed. Please check your email."
        redirect_to root_url
      else
        if params[:remember_me] == "1"
          sign_in(user)
        else
          sign_in_without_remember(user)
        end
        redirect_back_or user
      end
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
