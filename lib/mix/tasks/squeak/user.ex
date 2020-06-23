defmodule Mix.Tasks.Squeak.User do
  use Mix.Task
  import Mix.Squeak
  import Ecto.Query
  require Logger

  @shortdoc "Manages Squeak users"
  @moduledoc File.read!("docs/cli_tasks/users.md")

  def run(["list"]) do
    start_apps()

    shell_info("Listing all users:")
    query = from(Squeak.Users.User)

    Squeak.Repo.all(query, log: false)
    |> Enum.map(fn user ->
      shell_info(
        "[#{user.id}] username: '#{user.username}', email: '#{user.email}', role: #{user.role}"
      )
    end)
  end

  def run(["new", email, username | rest]) do
    start_apps()

    {options, [], []} =
      OptionParser.parse(rest,
        strict: [
          username: :string,
          password: :string,
          admin: :boolean
        ]
      )

    {password, generated_password?} =
      case Keyword.get(options, :password) do
        nil -> {:crypto.strong_rand_bytes(16) |> Base.encode64(), true}
        password -> {password, false}
      end

    admin? = Keyword.get(options, :admin, false)

    shell_info("""
    An user will be created with the following informations:
     - username: #{username}
     - email: #{email}
     - password: #{
      if(generated_password?,
        do: "[generated; you will have to reset-password to log-in]",
        else: password
      )
    }}
     - admin: #{if(admin?, do: "true", else: "false")}
    """)

    proceed? = shell_yes?("Continue?")

    if proceed? do
      params = %{
        username: username,
        email: email,
        password: password,
        password_confirmation: password
      }

      if admin? do
        {:ok, _user} = Squeak.Users.create_admin(params)
        Logger.info("Admin '#{username}' created")
      else
        {:ok, _user} = Squeak.Users.create_user(params)
        Logger.info("User '#{username}' created")
      end

      if generated_password? do
        Logger.info("Please use the reset password feature to log-in.")
        # PowEmailConfirmation.Ecto.Context.confirm_email(user, %{}, otp_app: :squeak)
      end
    else
      shell_info("User will not be created.")
    end
  end

  def run(["set", username | rest]) do
    start_apps()

    {options, [], []} =
      OptionParser.parse(rest,
        strict: [
          admin: :boolean
        ]
      )

    admin? = Keyword.get(options, :admin, false)

    user =
      Squeak.Users.User
      |> Ecto.Query.where(username: ^username)
      |> Squeak.Repo.one()

    if admin? do
      Squeak.Users.set_admin_role(user)
      Logger.info("User '#{username}' is now admin.")
    else
      Squeak.Users.set_user_role(user)
      Logger.info("User '#{username}' is now user.")
    end
  end
end
