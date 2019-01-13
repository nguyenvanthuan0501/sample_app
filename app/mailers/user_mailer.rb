class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t("static_pages.activate.subject")
  end

  def password_reset user
    @user = user
    mail to: user.email, subject: t("static_pages.new.password_reset")
  end
end
