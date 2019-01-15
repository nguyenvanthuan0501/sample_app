class SessionsController < ApplicationController
  before_action :load_user_by_mail, only: :create

  def new; end

  def create
    if @user.present? && @user.authenticate(params[:session][:password])
      if @user.activated?
        activated @user
      else
        flash[:warning] = t "static_pages.sessions.new.message"
        redirect_to root_path
      end
    else
      flash.now[:danger] = t "static_pages.sessions.new.error"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end

  private
  def activated user
    log_in user
    remember_true = Settings.user.controllers.sessions_controller.remember_true
    if params[:session][:remember_me] == remember_true
      remember user
    else
      forget user
    end
    redirect_back_or user
  end

  def load_user_by_mail
    @user = User.find_by email: params[:session][:email].downcase
    return if @user
    flash[:danger] = t "notification.not_found"
  end
end
