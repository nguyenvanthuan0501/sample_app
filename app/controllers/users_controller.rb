class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :load_user, only: %i(show edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate page: params[:page],
      per_page: Settings.user.controllers.users_controller.per_page
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = t "static_pages.home.h1"
      redirect_to @user
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes(user_params)
      # Handle a successful update
      flash[:success] = t "static_pages.sessions.profile.update"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.delete
      flash[:success] = t "static_pages.sessions.delete.title"
      redirect_to users_path
    else
      flash[:danger] = t "static_pages.sessions.delete.error"
      redirect_to root_path
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password,
      :password_confirmation)
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "notification.one"
    redirect_to root_path
  end

  # Before filters
  # Comfirm a logged_in user

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "notification.two"
    redirect_to login_path
  end

  def correct_user
    redirect_to root_path unless current_user? @user
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
