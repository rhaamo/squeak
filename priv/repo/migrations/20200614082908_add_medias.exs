defmodule Squeak.Repo.Migrations.AddMedias do
  use Ecto.Migration

  def change do
    create_if_not_exists table("medias") do
      add :filename, :string
      add :original_filename, :string
      add :type, :string
      add :mime, :string
      add :media, :string
      add :flake_id, :uuid
      timestamps()
    end
  end
end
