defmodule Squeak.Wiki.Page do
  use Ecto.Schema
  import Ecto.Query

  @primary_key {:id, :id, autogenerate: true}

  schema "pages" do
    field :name, :string
    field :content, :string
    field :flake_id, FlakeId.Ecto.Type, autogenerate: true

    belongs_to :namespace, Squeak.Namespaces.Namespace, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  def get_by_namespace_and_name(namespace, name) do
    from(t in Squeak.Wiki.Page, where: t.namespace_id == ^namespace.id, where: t.name == ^name)
    |> Squeak.Repo.one()
  end
end
