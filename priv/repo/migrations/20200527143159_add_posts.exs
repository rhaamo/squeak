defmodule Squeak.Repo.Migrations.AddPosts do
  use Ecto.Migration

  def change do
    create_if_not_exists table("posts") do
      add :subject, :string
      add :slug, :string
      add :content, :text
      add :draft, :boolean, default: true

      add :user_id, references(:users)

      timestamps()
    end
  end
end
