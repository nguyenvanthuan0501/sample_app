class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t("static_pages.activate.subject")
  end

  def password_reset
    @greeting = t("static_pages.activate.hi")

    mail to: "to@example.org"
  end
end
