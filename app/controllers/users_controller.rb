class UsersController < ApplicationController
  before_filter :signed_in_user,      only: [:index, :edit, :update, :destroy, :following, :followers]
  before_filter :correct_user,        only: [:edit, :update]
  before_filter :admin_user,          only: :destroy
  # ------- Ex 9.6 -------
  before_filter :info_signed_in_user, only: [:new, :create]


  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      UserMailer.signup_confirmation(@user).deliver
      flash[:notice] = 'To complete registration, please check you email'
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = 'Profile updated'
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
    unless current_user?(user)
      user.destroy
      flash[:success] = "User deleted."
    end
    redirect_to users_url
  end

  def following
    @title = 'Following'
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = 'Followers'
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  def confirm
    @user = User.find_by_remember_token(params[:id])
    if @user
      if @user.state == 'inactive'
        @user.activate!
        sign_in @user
        flash[:success] = "Account confirmed. Welcome #{@user.name}!"
        redirect_to @user
      else
        sign_out if signed_in?
        flash[:notice] = 'Account is already activated. Please sign in instead.'
        redirect_to signin_path
      end
    else
      flash[:error] = 'Invalid confirmation token'
      sign_out if signed_in?
      redirect_to root_url
    end
  end

  private


  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user?(@user)
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def info_signed_in_user
    redirect_to root_url, notice: "You are registered." if signed_in?
  end
end
