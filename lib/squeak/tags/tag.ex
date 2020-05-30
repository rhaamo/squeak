defmodule Squeak.Tags.Tag do
  use Ecto.Schema

  schema "tags" do
    field :name, :string

    has_many :posts_tags, Squeak.Tags.PostsTags
    has_many :posts, through: [:posts_tags, :post]
  end
end
