defmodule Squeak.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Squeak.Posts.Post.SubjectSlug

  @primary_key {:id, :id, autogenerate: true}

  schema "posts" do
    field :subject, :string
    field :slug, SubjectSlug.Type
    field :content, :string # text in reality
    field :draft, :boolean, default: true

    belongs_to :user, Squeak.Users.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:subject, :content, :user_id, :draft])
    |> SubjectSlug.maybe_generate_slug()
    |> validate_required([:subject, :content, :slug])
    |> SubjectSlug.unique_constraint()
  end

  @spec post_by_slug_query(String.t()) :: Ecto.Query.t()
  defp post_by_slug_query(slug) do
    from(t in Squeak.Posts.Post, where: t.slug == ^slug)
  end

  @spec get_post_by_slug(String.t()) :: Post.t() | nil
  def get_post_by_slug(slug) do
    slug
    |> post_by_slug_query
    |> Squeak.Repo.one
  end
end
