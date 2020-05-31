defmodule Squeak.Tags.Tag do
  use Ecto.Schema
  import Ecto.Query

  schema "tags" do
    field :name, :string

    has_many :posts_tags, Squeak.Tags.PostsTags
    has_many :posts, through: [:posts_tags, :post]
  end

  def get_tags(allow_empty \\ false) do
    tags =
      Squeak.Tags.Tag
      |> order_by([a], asc: a.name)

    if allow_empty do
      tags
      |> Squeak.Repo.all()
    else
      # TODO filter out empties
      tags
      |> Squeak.Repo.all()
    end
  end

  def delete_orphans() do
    Squeak.Repo.delete_all(
      from t in Squeak.Tags.Tag,
      where: fragment("? NOT IN (SELECT tag_id FROM posts_tags)", t.id)
    )
  end
end
