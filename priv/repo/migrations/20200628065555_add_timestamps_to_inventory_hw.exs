defmodule Squeak.Repo.Migrations.AddTimestampsToInventoryHw do
  use Ecto.Migration

  def change do
    alter table(:inventory_hw) do
      timestamps()
    end
  end
end
