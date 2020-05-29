defmodule Squeak.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  use Pow.Extension.Ecto.Schema, extensions: [PowResetPassword, PowEmailConfirmation]
  import Ecto.Changeset
  import Ecto.Query
  alias Squeak.Users.User.UsernameSlug

  schema "users" do
    field :role, :string, null: false, default: "user"
    field :username, :string, null: false
    field :slug, UsernameSlug.Type

    has_many :posts, Squeak.Posts.Post

    pow_user_fields()

    timestamps()
  end

  def changeset_role(user_or_changeset, attrs) do
    user_or_changeset
    |> Ecto.Changeset.cast(attrs, [:role])
    |> Ecto.Changeset.validate_inclusion(:role, ~w(user admin))
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
    |> cast(attrs, [:username])
    |> UsernameSlug.maybe_generate_slug()
    |> validate_required([:username, :slug])
    |> validate_length(:username, max: 25)
    |> UsernameSlug.unique_constraint()
  end

  @spec user_by_slug_query(String.t()) :: Ecto.Query.t()
  defp user_by_slug_query(slug) do
    from(t in Squeak.Users.User, where: t.slug == ^slug)
  end

  @spec get_user_by_slug(String.t()) :: User.t() | nil
  def get_user_by_slug(slug) do
    slug
    |> user_by_slug_query
    |> Squeak.Repo.one()
  end
end
