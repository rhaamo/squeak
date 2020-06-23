defmodule Squeak.Repo.Migrations.AddPgTrgmForWiki do
  use Ecto.Migration

  def up do
    execute("CREATE INDEX pages_trgm_idx ON pages USING GIN (to_tsvector('english', content))")
  end

  def down do
    execute("DROP INDEX pages_trgm_idx")
  end
end
