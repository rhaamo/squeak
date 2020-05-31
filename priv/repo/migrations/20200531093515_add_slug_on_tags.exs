defmodule Squeak.Repo.Migrations.AddSlugOnTags do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      add :slug, :string
    end

    create unique_index(:tags, [:slug])
  end
end
