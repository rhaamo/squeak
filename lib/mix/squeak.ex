defmodule Mix.Squeak do

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    :ecto_sql
  ]

  @repos [
    Squeak.Repo
  ]

  @doc "Start the required stuff for the repository"
  def start_apps do
    IO.puts("Starting apps...")
    Enum.each(@start_apps, &Application.ensure_all_started/1)
    IO.puts("Starting repos.")
    Enum.each(@repos, & &1.start_link(pool_size: 2))
  end

  def shell_prompt(prompt, defval \\ nil, defname \\ nil) do
    prompt_message = "#{prompt} [#{defname || defval}] "

    input =
      if mix_shell?(),
        do: Mix.shell().prompt(prompt_message),
        else: :io.get_line(prompt_message)

    case input do
      "\n" ->
        case defval do
          nil ->
            shell_prompt(prompt, defval, defname)

          defval ->
            defval
        end

      input ->
        String.trim(input)
    end
  end

  def shell_yes?(message) do
    if mix_shell?(),
      do: Mix.shell().yes?("Continue?"),
      else: shell_prompt(message, "Continue?") in ~w(Yn Y y)
  end

  def shell_info(message) do
    if mix_shell?(),
      do: Mix.shell().info(message),
      else: IO.puts(message)
  end

  def shell_error(message) do
    if mix_shell?(),
      do: Mix.shell().error(message),
      else: IO.puts(:stderr, message)
  end

  @doc "Performs a safe check whether `Mix.shell/0` is available (does not raise if Mix is not loaded)"
  def mix_shell?, do: :erlang.function_exported(Mix, :shell, 0)

end
