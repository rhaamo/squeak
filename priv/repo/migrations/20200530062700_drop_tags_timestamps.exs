defmodule Squeak.Repo.Migrations.DropTagsTimestamps do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      remove :inserted_at
      remove :updated_at
    end
  end
end
