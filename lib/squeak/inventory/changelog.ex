defmodule Squeak.Inventory.Changelog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  schema "inventory_changelog" do
    field :flake_id, FlakeId.Ecto.Type, autogenerate: true

    field :content, :string

    belongs_to :inventory_hw, Squeak.Inventory.Hw

    timestamps(type: :utc_datetime)
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :content,
      :hw_id
    ])
    |> validate_required([:content, :hw_id])
  end
end
