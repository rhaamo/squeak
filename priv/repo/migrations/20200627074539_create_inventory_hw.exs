defmodule Squeak.Repo.Migrations.CreateInventoryHw do
  use Ecto.Migration

  def change do
    create_if_not_exists table("inventory_hw") do
      add :flake_id, :uuid
      add :model, :string
      add :manufacturer, :string
      add :serial_number, :string
      add :function, :string
      add :description, :text
      add :notes, :text
      add :state, :integer
    end
  end
end
