defmodule SqueakWeb.PowResetPassword.MailerView do
  use SqueakWeb, :mailer_view

  def subject(:reset_password, _assigns), do: "Reset password link"
end
