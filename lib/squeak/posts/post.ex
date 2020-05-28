defmodule Squeak.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  schema "posts" do
    field :subject, :string
    field :slug, :string
    field :content, :string # text in reality
    field :draft, :boolean, default: true

    belongs_to :user, Squeak.Users.User

    timestamps()
  end

  @required_fields ~w(subject content user_id)
  @optional_fields ~w()

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:subject, :content, :user_id, :draft])
    |> validate_required([:subject, :content])
    |> unique_constraint(:slug)
  end
end
