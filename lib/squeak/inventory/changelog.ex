defmodule Squeak.Inventory.Changelog do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

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
      :inventory_hw_id,
      :inserted_at,
      :updated_at
    ])
    |> validate_required([:content, :inventory_hw_id, :inserted_at, :updated_at])
  end

  def get_changelog_for_item_query(item_id) do
    from(t in Squeak.Inventory.Changelog, where: t.inventory_hw_id == ^item_id)
  end
end
