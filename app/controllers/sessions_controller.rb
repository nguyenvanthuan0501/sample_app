class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user.present? && user.authenticate(params[:session][:password])
      log_in user
      check_remember user
      redirect_to user
    else
      flash.now[:danger] = t "static_pages.sessions.new.error"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end

  def check_remember user
    remember_true = Settings.user.controllers.sessions_controller.remember_true
    if params[:session][:remember_me] == remember_true
      remember user
    else
      forget user
    end
  end
end
