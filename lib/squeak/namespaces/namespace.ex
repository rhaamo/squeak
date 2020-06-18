defmodule Squeak.Namespaces.Namespace do
  use Ecto.Schema
  use Arbor.Tree, foreign_key: :parent_id, foreign_key_type: :binary_id

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "namespaces" do
    field :name, :string
    belongs_to :parent, __MODULE__
  end
end
