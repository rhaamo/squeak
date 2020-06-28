defmodule Squeak.States.Config do
  use GenServer
  require Logger

  @moduledoc """
  Holds the config
  """

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def fetch_config(table) do
    # [key, default value]
    [
      [:registration, false],
      [:pagination, %{posts: 10}],
      [:app_name, "Squeaky website"],
      [:gopher, %{ip: {0, 0, 0, 0}, port: 1234, enabled: false}],
      [:hw_inventory, %{enabled: true, link_name: "Workbench"}]
    ]
    |> Enum.each(fn x ->
      [k, v] = x
      value = Application.get_env(:squeak, k, v)
      :ets.insert(table, {k, value})
    end)

    Logger.info("Config has been loaded in memory.")
    Logger.debug(inspect(:ets.tab2list(:inmemory_config)))
  end

  def init(:ok) do
    table = :ets.new(:inmemory_config, [:named_table, :protected])
    fetch_config(table)
    {:ok, table}
  end

  def find(key) do
    case :ets.lookup(:inmemory_config, key) do
      [{^key, value}] -> {:ok, value}
      [] -> :error
    end
  end

  @doc "Get a value from the config"
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def handle_call({:get, key}, _from, table) do
    case find(key) do
      {:ok, value} -> {:reply, value, table}
      :error -> {:reply, :error, table}
    end
  end
end
