defmodule SqueakWeb.AdminController do
  use SqueakWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
