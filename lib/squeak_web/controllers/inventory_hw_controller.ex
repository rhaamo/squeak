defmodule SqueakWeb.InventoryHwController do
  use SqueakWeb, :controller
  require Ecto.Query

  plug(SqueakWeb.Plugs.EnsureRole, :admin when action not in [:index, :show])

  def index(conn, _params) do
    current_user = Pow.Plug.current_user(conn)

    items =
      Squeak.Inventory.Hw
      |> Ecto.Query.order_by([a], a.model)

    items =
      if current_user do
        items
      else
        items |> Ecto.Query.where([a], a.private == false)
      end
      |> Squeak.Repo.all()

    render(conn, "index.html", items: items)
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"id" => flake_id}) do
    item = Squeak.Inventory.Hw.get_item_by_flake_id(flake_id)

    if is_nil(item) do
      conn
      |> render(:"404")
    end

    render(conn, "show.html", item: item)
  end

  def new(conn, _params) do
    changeset = Squeak.Inventory.Hw.changeset(%Squeak.Inventory.Hw{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"hw" => item_params}) do
    date = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    params =
      item_params
      |> Map.put("updated_at", date)
      |> Map.put("inserted_at", date)

    changeset = Squeak.Inventory.Hw.changeset(%Squeak.Inventory.Hw{}, params)

    if changeset.valid? do
      {:ok, obj} = Squeak.Repo.insert(changeset)

      conn
      |> put_flash(:info, "Item has been saved.")
      |> redirect(to: SqueakWeb.Router.Helpers.inventory_hw_path(conn, :show, obj.flake_id))
    else
      render(conn, "new.html", changeset: %{changeset | action: :insert})
    end
  end

  def edit(conn, %{"id" => item_id}) do
    item = Squeak.Inventory.Hw.get_item_by_flake_id(item_id)

    if is_nil(item) do
      conn
      |> redirect(to: SqueakWeb.Router.Helpers.inventory_hw_path(conn, :index))
    end

    changeset = Squeak.Inventory.Hw.changeset(item, %{})
    render(conn, "edit.html", changeset: changeset, item: item)
  end

  def update(conn, %{"id" => item_id, "hw" => item_params}) do
    item = Squeak.Inventory.Hw.get_item_by_flake_id(item_id)

    if is_nil(item) do
      conn
      |> redirect(to: SqueakWeb.Router.Helpers.inventory_hw_path(conn, :index))
    end

    date_now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    params =
      item_params
      |> Map.put("updated_at", date_now)

    changeset = Squeak.Inventory.Hw.changeset(item, params)

    if changeset.valid? do
      {:ok, _obj} = Squeak.Repo.update(changeset)

      conn
      |> put_flash(:info, "Item updated.")
      |> redirect(
        to:
          SqueakWeb.Router.Helpers.inventory_hw_path(
            conn,
            :show,
            item.flake_id
          )
      )
    else
      render(conn, "edit.html", changeset: changeset, item: item)
    end
  end

  def delete(conn, %{"id" => item_id}) do
    item = Squeak.Inventory.Hw.get_item_by_flake_id(item_id)

    if is_nil(item) do
      conn
      |> redirect(to: SqueakWeb.Router.Helpers.inventory_hw_path(conn, :index))
    end

    case Squeak.Repo.delete(item) do
      {:ok, _obj} ->
        conn
        |> put_flash(:info, "Item deleted.")
        |> redirect(
          to:
            SqueakWeb.Router.Helpers.inventory_hw_path(
              conn,
              :index
            )
        )

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Cannot delete item.")
        |> redirect(
          to:
            SqueakWeb.Router.Helpers.inventory_hw_path(
              conn,
              :index,
              item.flake_id
            )
        )
    end
  end
end
