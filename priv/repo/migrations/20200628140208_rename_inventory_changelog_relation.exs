defmodule Squeak.Repo.Migrations.RenameInventoryChangelogRelation do
  use Ecto.Migration

  def change do
    rename table(:inventory_changelog), :hw_id, to: :inventory_hw_id
  end
end
