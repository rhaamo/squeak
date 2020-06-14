defmodule Squeak.Repo.Migrations.DropMediaType do
  use Ecto.Migration

  def change do
    alter table(:medias) do
      remove :type
    end
  end
end
