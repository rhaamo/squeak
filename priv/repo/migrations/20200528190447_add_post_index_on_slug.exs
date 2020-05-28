defmodule Squeak.Repo.Migrations.AddPostIndexOnSlug do
  use Ecto.Migration

  def change do
    create unique_index(:posts, [:slug])
  end
end
