defmodule Mix.Tasks.Squeak.User do
  use Mix.Task
  import Mix.Squeak
  import Ecto.Query
  require Logger

  @shortdoc "Manages Squeak users"
  @moduledoc """
  aaa
  """

  def run(["list"]) do
    start_apps()

    shell_info("Listing all users:")
    query = from(Squeak.User)
    Squeak.Repo.all(query, log: false)
    |> Enum.map(fn user ->
      shell_info("[#{user.id}] username: '#{user.username}', email: '#{user.email}', role: #{user.role}")
    end)
  end

  def run(["new", email, username | rest ]) do
    start_apps()

    {options, [], []} = OptionParser.parse(rest, strict: [
      username: :string,
      password: :string,
      admin: :boolean
    ])

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
     - password: #{if(generated_password?, do: "[generated; you will have to reset-password to log-in]", else: password)}}
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
        {:ok, _user} = Squeak.User.create_admin(params)
        Logger.info("Admin '#{username}' created")
      else
        {:ok, _user} = Squeak.User.create_user(params)
        Logger.info("User '#{username}' created")
      end

      if generated_password? do
        Logger.info("Please use the reset password feature to log-in.")
      end
    else
      shell_info("User will not be created.")
    end
  end
end
