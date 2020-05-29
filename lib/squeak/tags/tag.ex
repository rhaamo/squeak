defmodule Squeak.Tags.Tag do
  use Ecto.Schema

  schema "tags" do
    field :name, :string
    timestamps()
  end
end
