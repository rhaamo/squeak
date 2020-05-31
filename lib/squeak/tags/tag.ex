defmodule Squeak.Tags.Tag do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Squeak.Tags.Tag.NameSlug

  schema "tags" do
    field :name, :string
    field :slug, NameSlug.Type

    has_many :posts_tags, Squeak.Tags.PostsTags
    has_many :posts, through: [:posts_tags, :post]
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> NameSlug.maybe_generate_slug()
    |> validate_required([:name, :slug])
    |> NameSlug.unique_constraint()
  end

  def get_tags() do
    Squeak.Tags.Tag
    |> order_by([a], asc: a.name)
    |> Squeak.Repo.all()
  end

  def delete_orphans() do
    Squeak.Repo.delete_all(
      from t in Squeak.Tags.Tag,
        where: fragment("? NOT IN (SELECT tag_id FROM posts_tags)", t.id)
    )
  end

  @spec tag_by_slug_query(String.t()) :: Ecto.Query.t()
  defp tag_by_slug_query(slug) do
    from(t in Squeak.Tags.Tag, where: t.slug == ^slug)
  end

  @spec get_tag_by_slug(String.t()) :: Post.t() | nil
  def get_tag_by_slug(slug) do
    slug
    |> tag_by_slug_query
    |> Squeak.Repo.one()
  end
end
