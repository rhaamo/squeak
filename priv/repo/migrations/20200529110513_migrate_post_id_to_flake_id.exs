defmodule Squeak.Repo.Migrations.MigratePostIdToFlakeId do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      remove :id
      add :id, :uuid, primary_key: true
    end
  end
end
