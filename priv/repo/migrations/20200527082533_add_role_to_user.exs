defmodule Squeak.Repo.Migrations.AddRoleToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role, :string, default: "user"
    end

  end
end
