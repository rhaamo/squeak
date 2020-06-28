defmodule SqueakWeb.InventoryChangelogController do
  use SqueakWeb, :controller
  require Ecto.Query

  plug(SqueakWeb.Plugs.EnsureRole, :admin when action not in [:index, :show])

  def index(conn, %{"inventory_hw_id" => item_id}) do
    item = Squeak.Inventory.Hw.get_item_by_flake_id(item_id)

    if is_nil(item) do
      conn
      |> redirect(to: SqueakWeb.Router.Helpers.inventory_hw_path(conn, :index))
    end

    changelog =
      Squeak.Inventory.Changelog.get_changelog_for_item_query(item.id)
      |> Ecto.Query.order_by([a], asc: a.inserted_at)
      |> Squeak.Repo.all()

    conn
    |> render("index.html", changelog: changelog, item: item)
  end

  def new(conn, %{"inventory_hw_id" => item_id}) do
    item = Squeak.Inventory.Hw.get_item_by_flake_id(item_id)

    if is_nil(item) do
      conn
      |> redirect(to: SqueakWeb.Router.Helpers.inventory_hw_path(conn, :index))
    end

    changeset =
      Squeak.Inventory.Changelog.changeset(%Squeak.Inventory.Changelog{}, %{
        date: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
      })

    render(conn, "new.html", changeset: changeset, item: item)
  end

  def create(conn, %{"inventory_hw_id" => item_id, "changelog" => log_params}) do
    item = Squeak.Inventory.Hw.get_item_by_flake_id(item_id)

    if is_nil(item) do
      conn
      |> redirect(to: SqueakWeb.Router.Helpers.inventory_hw_path(conn, :index))
    end

    date_log =
      log_params["date"]
      |> Timex.to_datetime()

    params =
      log_params
      |> Map.put("updated_at", date_log)
      |> Map.put("inserted_at", date_log)
      |> Map.put("inventory_hw_id", item.id)

    changeset = Squeak.Inventory.Changelog.changeset(%Squeak.Inventory.Changelog{}, params)

    if changeset.valid? do
      {:ok, _obj} = Squeak.Repo.insert(changeset)

      conn
      |> put_flash(:info, "Work log added.")
      |> redirect(
        to:
          SqueakWeb.Router.Helpers.inventory_hw_inventory_changelog_path(
            conn,
            :index,
            item.flake_id
          )
      )
    else
      render(conn, "new.html", changeset: %{changeset | action: :insert}, item: item)
    end
  end

  def edit(conn, %{"inventory_hw_id" => item_id, "id" => change_id}) do
    item = Squeak.Inventory.Hw.get_item_by_flake_id(item_id)

    if is_nil(item) do
      conn
      |> redirect(to: SqueakWeb.Router.Helpers.inventory_hw_path(conn, :index))
    end

    change = Squeak.Inventory.Changelog.get_item_by_flake_id(change_id)

    if is_nil(change) do
      conn
      |> redirect(
        to:
          SqueakWeb.Router.Helpers.inventory_hw_inventory_changelog_path(
            conn,
            :index,
            item.flake_id
          )
      )
    end

    changeset = Squeak.Inventory.Changelog.changeset(change, %{date: change.inserted_at})
    render(conn, "edit.html", changeset: changeset, item: item, change: change)
  end

  def update(conn, %{"inventory_hw_id" => item_id, "id" => change_id, "changelog" => log_params}) do
    item = Squeak.Inventory.Hw.get_item_by_flake_id(item_id)

    if is_nil(item) do
      conn
      |> redirect(to: SqueakWeb.Router.Helpers.inventory_hw_path(conn, :index))
    end

    change = Squeak.Inventory.Changelog.get_item_by_flake_id(change_id)

    if is_nil(change) do
      conn
      |> redirect(
        to:
          SqueakWeb.Router.Helpers.inventory_hw_inventory_changelog_path(
            conn,
            :index,
            item.flake_id
          )
      )
    end

    date_now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    date_log =
      log_params["date"]
      |> Timex.to_datetime()

    params =
      log_params
      |> Map.put("inserted_at", date_log)
      |> Map.put("updated_at", date_now)

    changeset = Squeak.Inventory.Changelog.changeset(change, params)

    if changeset.valid? do
      {:ok, _obj} = Squeak.Repo.update(changeset)

      conn
      |> put_flash(:info, "Entry updated.")
      |> redirect(
        to:
          SqueakWeb.Router.Helpers.inventory_hw_inventory_changelog_path(
            conn,
            :index,
            item.flake_id
          )
      )
    else
      render(conn, "edit.html", changeset: changeset, item: item, change: change)
    end
  end

  def delete(conn, %{"inventory_hw_id" => item_id, "id" => change_id}) do
    item = Squeak.Inventory.Hw.get_item_by_flake_id(item_id)

    if is_nil(item) do
      conn
      |> redirect(to: SqueakWeb.Router.Helpers.inventory_hw_path(conn, :index))
    end

    change = Squeak.Inventory.Changelog.get_item_by_flake_id(change_id)

    if is_nil(change) do
      conn
      |> redirect(
        to:
          SqueakWeb.Router.Helpers.inventory_hw_inventory_changelog_path(
            conn,
            :index,
            item.flake_id
          )
      )
    end

    case Squeak.Repo.delete(change) do
      {:ok, _obj} ->
        conn
        |> put_flash(:info, "Entry deleted.")
        |> redirect(
          to:
            SqueakWeb.Router.Helpers.inventory_hw_inventory_changelog_path(
              conn,
              :index,
              item.flake_id
            )
        )

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Cannot delete entry.")
        |> redirect(
          to:
            SqueakWeb.Router.Helpers.inventory_hw_inventory_changelog_path(
              conn,
              :index,
              item.flake_id
            )
        )
    end
  end
end
