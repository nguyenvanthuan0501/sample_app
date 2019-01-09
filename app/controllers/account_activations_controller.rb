class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]
    if shoud_edit? user
      user.activate
      log_in user
      flash[:success] = t "static_pages.activate.subject2"
      redirect_to user
    else
      flash[:danger] = t "static_pages.activate.subject_danger"
      redirect_to root_path
    end
  end

  def shoud_edit? user
    user && !user.activated? && user.authenticated?(:activation, params[:id])
  end
end
