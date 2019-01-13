class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "static_pages.new.email_info"
      redirect_to root_path
    else
      flash.now[:danger] = t "static_pages.new.email_danger"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, t("static_pages.password_reset.error")
      render :edit
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = t("static_pages.password_reset.success")
      redirect_to @user
    else
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by email: params[:email]
  end

  # Confirm a valid user

  def valid_user
    return if @user.present? && @user.activated? &&
              @user.authenticated?(:reset, params[:id])

    redirect_to root_path
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t "static_pages.password_resets.expiredpass"
    redirect_to new_password_reset_url
  end
end
