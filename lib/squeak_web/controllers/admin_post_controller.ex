defmodule SqueakWeb.AdminPostController do
  use SqueakWeb, :controller
  alias Squeak.Posts.Post

  def new(conn, _params) do
    changeset = Post.changeset(%Post{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    user = Pow.Plug.current_user(conn)
    changeset = Post.changeset(%Post{}, Map.put(post_params, "user_id", user.id))

    if changeset.valid? do
      Squeak.Repo.insert(changeset)

      conn
      |> put_flash(:info, "Post has been saved.")
      |> redirect(to: SqueakWeb.Router.Helpers.admin_path(conn, :index))
    else
      render(conn, "new.html", changeset: %{changeset | action: :insert})
    end
  end

end
