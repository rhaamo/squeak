defmodule Squeak.Inventory.Hw do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

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
    field :private, :boolean, default: false

    has_many :changelogs, Squeak.Inventory.Changelog

    # category
    # medias
    # has_many :links
    # has_many :options
    # has_one :wiki_page

    timestamps(type: :utc_datetime)
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
    |> validate_required([:description, :state, :model, :function])
  end

  def state_to_keyword(state) do
    case state do
      1 -> :new
      2 -> :used
      3 -> :has_issues_working
      4 -> :has_issues_not_working
      _ -> :unknown
    end
  end

  def form_states do
    [
      Unknown: 99999,
      New: 1,
      Used: 2,
      "Has Issues (working)": 3,
      "Has Issues (not working)": 4
    ]
  end

  def state_to_human(state) do
    case state do
      1 -> "New"
      2 -> "Used"
      3 -> "Has Issues (working)"
      4 -> "Has Issues (not working)"
      _ -> "Unknown"
    end
  end

  def get_item_by_flake_id_query(flake_id) do
    from(t in Squeak.Inventory.Hw, where: t.flake_id == ^flake_id)
  end

  def get_item_by_flake_id(flake_id) do
    flake_id
    |> get_item_by_flake_id_query
    |> Squeak.Repo.one()
  end
end
