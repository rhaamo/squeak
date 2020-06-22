defmodule Squeak.Namespaces.Namespace do
  use Ecto.Schema
  use Arbor.Tree, foreign_key: :parent_id, foreign_key_type: :binary_id
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "namespaces" do
    field :name, :string
    belongs_to :parent, __MODULE__
    has_many :pages, Squeak.Wiki.Page
  end

  def create_namespace(name, parent_id \\ nil) do
    namespace =
      case parent_id do
        nil -> %Squeak.Namespaces.Namespace{name: name}
        parent_id -> %Squeak.Namespaces.Namespace{name: name, parent_id: parent_id}
      end

    namespace |> Squeak.Repo.insert!()
  end

  def get_or_create_namespace(namespace, parent_id) do
    ns = get_by_name_and_parent_id(namespace, parent_id)

    if is_nil(ns) do
      create_namespace(namespace, parent_id)
    else
      ns
    end
  end

  def get_or_create_namespaces([head | tail], parent_id \\ nil, records \\ []) do
    case tail do
      [] ->
        ns = Squeak.Namespaces.Namespace.get_or_create_namespace(head, parent_id)
        records ++ [ns]

      tail ->
        ns = Squeak.Namespaces.Namespace.get_or_create_namespace(head, parent_id)

        if is_nil(ns) do
          records ++ [ns]
        else
          get_or_create_namespaces(tail, ns.id, records ++ [ns])
        end
    end
  end

  def get_by_name_and_parent_id_query(name, parent_id) do
    if is_nil(parent_id) do
      from(t in Squeak.Namespaces.Namespace, where: t.name == ^name, where: is_nil(t.parent_id))
    else
      from(t in Squeak.Namespaces.Namespace,
        where: t.name == ^name,
        where: t.parent_id == ^parent_id
      )
    end
  end

  def get_by_name_and_parent_id(name, parent_id) do
    get_by_name_and_parent_id_query(name, parent_id)
    |> Squeak.Repo.one()
  end

  def resolve_tree([]), do: [nil]

  def resolve_tree([head | tail], parent_id \\ nil, records \\ []) do
    case tail do
      [] ->
        ns = Squeak.Namespaces.Namespace.get_by_name_and_parent_id(head, parent_id)
        records ++ [ns]

      tail ->
        ns = Squeak.Namespaces.Namespace.get_by_name_and_parent_id(head, parent_id)

        if is_nil(ns) do
          records ++ [ns]
        else
          resolve_tree(tail, ns.id, records ++ [ns])
        end
    end
  end
end
