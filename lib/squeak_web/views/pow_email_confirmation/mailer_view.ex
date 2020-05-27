defmodule SqueakWeb.PowEmailConfirmation.MailerView do
  use SqueakWeb, :mailer_view

  def subject(:email_confirmation, _assigns), do: "Confirm your email address"
end
