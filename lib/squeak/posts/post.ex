defmodule Squeak.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Squeak.Posts.Post.SubjectSlug

  @primary_key {:id, :id, autogenerate: true}

  schema "posts" do
    field :subject, :string
    field :slug, SubjectSlug.Type
    # text in reality
    field :content, :string
    field :draft, :boolean, default: true
    field :flake_id, FlakeId.Ecto.Type, autogenerate: true

    has_many :posts_tags, Squeak.Tags.PostsTags
    many_to_many :tags, Squeak.Tags.Tag, join_through: "posts_tags"
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
    |> put_assoc(:tags, parse_tags(attrs))
  end

  def changeset_update(post, attrs) do
    post
    |> cast(attrs, [:subject, :content, :user_id, :draft])
    |> SubjectSlug.force_generate_slug()
    |> validate_required([:subject, :content, :slug])
    |> SubjectSlug.unique_constraint()
    |> put_assoc(:tags, parse_tags(attrs))
  end

  defp parse_tags(params) do
    (params["tags"] || "")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> insert_and_get_all()
  end

  defp insert_and_get_all([]) do
    []
  end
  defp insert_and_get_all(names) do
    maps = Enum.map(names, &%{name: &1})
    Squeak.Repo.insert_all Squeak.Tags.Tag, maps, on_conflict: :nothing
    Squeak.Repo.all(from t in Squeak.Tags.Tag, where: t.name in ^names)
  end

  @spec post_by_slug_query(String.t()) :: Ecto.Query.t()
  defp post_by_slug_query(slug) do
    from(t in Squeak.Posts.Post, where: t.slug == ^slug)
  end

  @spec post_by_slug_and_user_id_query(String.t(), Integer.t()) :: Ecto.Query.t()
  defp post_by_slug_and_user_id_query(slug, user_id) do
    from(t in Squeak.Posts.Post, where: t.slug == ^slug, where: t.user_id == ^user_id)
  end

  @spec get_post_by_slug(String.t()) :: Post.t() | nil
  def get_post_by_slug(slug) do
    slug
    |> post_by_slug_query
    |> Squeak.Repo.one()
  end

  @spec get_post_by_slug_and_user_id(String.t(), Integer.t()) :: Post.t() | nil
  def get_post_by_slug_and_user_id(slug, user_id) do
    slug
    |> post_by_slug_and_user_id_query(user_id)
    |> Squeak.Repo.one()
  end

  def is_owner(post, conn) do
    current_user = Pow.Plug.current_user(conn)

    if is_nil(current_user) do
      false
    else
      if post.user_id == current_user.id do
        true
      else
        false
      end
    end
  end
end
