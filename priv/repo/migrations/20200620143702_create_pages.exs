defmodule Squeak.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create_if_not_exists table("pages") do
      add :name, :string
      add :content, :text
      add :flake_id, :uuid
      add :namespace_id, references(:namespaces, type: :uuid)

      timestamps()
    end
  end
end
