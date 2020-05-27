defmodule SqueakWeb.PageControllerTest do
  use SqueakWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "squeak"
  end
end
