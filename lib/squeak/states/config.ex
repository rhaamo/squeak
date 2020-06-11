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
    items = [
      [:registration, false],
      [:pagination, %{posts: 10}],
      [:app_name, "Squeaky website"]
    ]

    Enum.map(items, fn x ->
      [k, v] = x
      :ets.insert(table, {x, Application.get_env(:squeak, k, v)})
    end)

    Logger.info("Config has been loaded in memory.")
  end

  def init(:ok) do
    table = :ets.new(:config, [:named_table, :protected])
    fetch_config(table)
    {:ok, table}
  end

  def find(key) do
    case :ets.lookup(:config, key) do
      [{^key, value}] -> {:ok, value}
      [] -> :error
    end
  end

  @doc "Get a value from the config"
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def handle_call({:get, key}, _from, _table) do
    case find(key) do
      {:ok, value} -> value
      :error -> :error
    end
  end
end
