defmodule Squeak.Repo.Migrations.AddInventoryChangelog do
  use Ecto.Migration

  def change do
    create_if_not_exists table("inventory_changelog") do
      add :flake_id, :uuid
      add :content, :text
      add :hw_id, references(:inventory_hw)
      timestamps()
    end
  end
end
