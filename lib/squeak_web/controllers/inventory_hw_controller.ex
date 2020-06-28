defmodule SqueakWeb.InventoryHwController do
  use SqueakWeb, :controller
  require Ecto.Query

  def index(conn, _params) do
    items =
      Squeak.Inventory.Hw
      |> Ecto.Query.order_by([a], a.model)
      |> Squeak.Repo.all()

    render(conn, "index.html", items: items)
  end
end
