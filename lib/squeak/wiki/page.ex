defmodule Squeak.Wiki.Page do
  use Ecto.Schema
  import Ecto.Query
  require Logger

  @primary_key {:id, :id, autogenerate: true}

  schema "pages" do
    field :name, :string
    field :content, :string
    field :flake_id, FlakeId.Ecto.Type, autogenerate: true

    belongs_to :namespace, Squeak.Namespaces.Namespace, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  def split_path(path) do
    fullpath = Enum.reverse(String.split(path, ":"))
    page = hd(fullpath)
    namespaces = tl(fullpath)
    namespaces = namespaces |> Enum.reverse()
    Logger.info("Got page: #{inspect(page)} and namespaces: #{inspect(namespaces)}")
    [namespaces, page]
  end

  def get_by_namespace_id_and_name(namespace_id, name) do
    if is_nil(namespace_id) do
      from(t in Squeak.Wiki.Page, where: is_nil(t.namespace_id), where: t.name == ^name)
    else
      from(t in Squeak.Wiki.Page, where: t.namespace_id == ^namespace_id, where: t.name == ^name)
    end
    |> Squeak.Repo.one()
  end

  def get_rootless_pages_query() do
    from(t in Squeak.Wiki.Page, where: is_nil(t.namespace_id))
  end

  def get_rootless_pages() do
    from(t in Squeak.Wiki.Page, where: is_nil(t.namespace_id))
    |> Squeak.Repo.all()
  end

  def get_in_namespace_query(namespace) do
    from(t in Squeak.Wiki.Page, where: t.namespace_id == ^namespace.id)
  end

  def get_in_namespace(namespace) do
    get_in_namespace_query(namespace)
    |> Squeak.Repo.all()
  end
end
