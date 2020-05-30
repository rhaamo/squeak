defmodule Squeak.Tags.Tag do
  use Ecto.Schema
  require Ecto.Query

  schema "tags" do
    field :name, :string

    has_many :posts_tags, Squeak.Tags.PostsTags
    has_many :posts, through: [:posts_tags, :post]
  end

  def get_tags(allow_empty \\ false) do
    tags = Squeak.Tags.Tag
    |> Ecto.Query.order_by([a], asc: a.name)

    if allow_empty do
      tags
      |> Squeak.Repo.all()
    else
      # TODO filter out empties
      tags
      |> Squeak.Repo.all()
    end
  end
end
