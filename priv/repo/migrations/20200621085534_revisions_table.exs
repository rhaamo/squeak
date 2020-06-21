defmodule Squeak.Repo.Migrations.RevisionsTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:revisions) do
      add :item_type, :string, null: false
      add :item_id, :integer, null: false
      add :encoded_item, :binary, null: false
      add :metadata, :map, null: false
      add :revision, :integer, null: false
      add :struct_name, :string
    end

    create_if_not_exists index(:revisions, [:item_type, :item_id])
    create_if_not_exists unique_index(:revisions, [:item_type, :item_id, :revision])
  end
end
