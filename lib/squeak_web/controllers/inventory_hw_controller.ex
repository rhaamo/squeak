defmodule SqueakWeb.InventoryHwController do
  use SqueakWeb, :controller
  require Ecto.Query

  def index(conn, _params) do
    current_user = Pow.Plug.current_user(conn)

    items =
      Squeak.Inventory.Hw
      |> Ecto.Query.order_by([a], a.model)

    items =
      if current_user do
        items
      else
        items |> Ecto.Query.where([a], a.private == true)
      end
      |> Squeak.Repo.all()

    render(conn, "index.html", items: items)
  end
end
