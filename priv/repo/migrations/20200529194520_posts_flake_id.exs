defmodule Squeak.Repo.Migrations.PostsFlakeId do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :flake_id, :uuid
    end
  end
end
