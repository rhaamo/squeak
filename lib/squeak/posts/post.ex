defmodule Squeak.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
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
    |> validate_required([:subject, :content])
    |> SubjectSlug.maybe_generate_slug
    |> SubjectSlug.unique_constraint
  end
end
