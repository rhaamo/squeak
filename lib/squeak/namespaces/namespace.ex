defmodule Squeak.Namespaces.Namespace do
  use Ecto.Schema
  use Arbor.Tree, foreign_key: :parent_id, foreign_key_type: :binary_id

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "namespaces" do
    field :name, :string
    belongs_to :parent, __MODULE__
  end

  def create_namespace(name), do: create_namespace(name, parent: nil)

  def create_namespace(name, parent: parent) do
    namespace =
      case parent do
        nil -> %Squeak.Namespaces.Namespace{name: name}
        parent -> %Squeak.Namespaces.Namespace{name: name, parent_id: parent.id}
      end
    namespace |> Squeak.Repo.insert!
  end
end
