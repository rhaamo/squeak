defmodule Squeak.Repo.Migrations.AddPrivateToInventoryHw do
  use Ecto.Migration

  def change do
    alter table(:inventory_hw) do
      add :private, :boolean, default: false
    end
  end
end
