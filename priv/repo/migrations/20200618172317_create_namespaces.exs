defmodule Squeak.Repo.Migrations.CreateNamespaces do
  use Ecto.Migration

  def change do
    create_if_not_exists table("namespaces", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :parent_id, references(:namespaces, type: :binary_id), null: true
    end

    create index :namespaces, [:parent_id]
  end
end
