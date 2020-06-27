defmodule Squeak.Inventory.Hw do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  schema "inventory_hw" do
    field :flake_id, FlakeId.Ecto.Type, autogenerate: true

    field :model, :string
    field :manufacturer, :string
    field :serial_number, :string
    field :function, :string
    field :description, :string
    field :notes, :string
    field :state, :integer

    # category
    # photos
    # has_many :links
    # has_one :wiki_page
    # has_many :changelog_entries
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :model,
      :manufacturer,
      :serial_number,
      :function,
      :description,
      :notes,
      :state
    ])
    |> validate_required([:description, :state])
  end

  def state(state) do
    case state do
      1 -> :new
      2 -> :used
      3 -> :has_issues
      _ -> :unknown
    end
  end
end
