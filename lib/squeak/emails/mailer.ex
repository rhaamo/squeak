defmodule Squeak.Emails.Mailer do
  @moduledoc """
  Defines the Squeak mailer.

  The module contains functions to delivery email using Swoosh.Mailer.
  """

  use Pow.Phoenix.Mailer
  use Swoosh.Mailer, otp_app: :squeak

  import Swoosh.Email

  require Logger

  @impl true
  def cast(%{user: user, subject: subject, text: text, html: html}) do
    mail_config = Application.get_env(:squeak, :mailer)

    %Swoosh.Email{}
    |> to({"", user.email})
    |> from({mail_config[:from_name], mail_config[:from]})
    |> subject(subject)
    |> html_body(html)
    |> text_body(text)
  end

  @impl true
  def process(email) do
    email
    |> deliver()
    |> log_warnings()
  end

  defp log_warnings({:error, reason}) do
    Logger.warn("Mailer backend failed with: #{inspect(reason)}")
  end

  defp log_warnings({:ok, reason}), do: {:ok, reason}
end
