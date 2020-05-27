defmodule SqueakWeb.EnsureRolePlugTest do
  use SqueakWeb.ConnCase

  alias SqueakWeb.Plugs.EnsureRole

  @opts ~w(admin)a
  @user %{id: 1, role: "user"}
  @admin %{id: 2, role: "admin"}

  setup do
    conn =
      build_conn()
      |> Plug.Conn.put_private(:plug_session, %{})
      |> Plug.Conn.put_private(:plug_session_fetch, :done)
      |> Pow.Plug.put_config(otp_app: :my_app)
      |> fetch_flash()

    {:ok, conn: conn}
  end

  test "call/2 with no user", %{conn: conn} do
    opts = EnsureRole.init(@opts)
    conn = EnsureRole.call(conn, opts)

    assert conn.halted
    assert Phoenix.ConnTest.redirected_to(conn) == Routes.page_path(conn, :index)
  end

  test "call/2 with non-admin user", %{conn: conn} do
    opts = EnsureRole.init(@opts)
    conn =
      conn
      |> Pow.Plug.assign_current_user(@user, otp_app: :my_app)
      |> EnsureRole.call(opts)

    assert conn.halted
    assert Phoenix.ConnTest.redirected_to(conn) == Routes.page_path(conn, :index)
  end

  test "call/2 with non-admin user and multiple roles", %{conn: conn} do
    opts = EnsureRole.init(~w(user admin)a)
    conn =
      conn
      |> Pow.Plug.assign_current_user(@user, otp_app: :my_app)
      |> EnsureRole.call(opts)

    refute conn.halted
  end

  test "call/2 with admin user", %{conn: conn} do
    opts = EnsureRole.init(@opts)
    conn =
      conn
      |> Pow.Plug.assign_current_user(@admin, otp_app: :my_app)
      |> EnsureRole.call(opts)

    refute conn.halted
  end
end
