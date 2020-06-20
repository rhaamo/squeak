defmodule Squeak.Wiki.Page do
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: true}

  schema "pages" do
    field :name, :string
    field :content, :string
    field :flake_id, FlakeId.Ecto.Type, autogenerate: true

    belongs_to :namespace, Squeak.Namespaces.Namespace, type: :binary_id

    timestamps(type: :utc_datetime)
  end
end
