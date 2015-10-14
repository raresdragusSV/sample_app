class UsersController < ApplicationController
  before_filter :info_signed_in_user, only: [:new, :create]
  before_filter :signed_in_user,      only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,        only: [:edit, :update]
  before_filter :admin_user,          only: :destroy


  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = 'Welcome to the Sample App!'
      sign_in @user
      redirect_to @user
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
    User.find(params[:id])
    unless current_user?(user)
      user.destroy
      flash[:success] = "User deleted."
    end
    redirect_to users_url
  end

  private

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: 'Please sign in.'
    end
  end

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
