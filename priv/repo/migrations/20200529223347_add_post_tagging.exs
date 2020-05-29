defmodule Squeak.Repo.Migrations.AddPostTagging do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
      timestamps()
    end

    create unique_index(:tags, [:name])

    create table(:posts_tags, primary_key: false) do
      add :post_id, references(:posts)
      add :tag_id, references(:tags)
    end
  end
end
