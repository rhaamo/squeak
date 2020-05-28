defmodule SqueakWeb.AdminPostController do
  use SqueakWeb, :controller
  alias Squeak.Posts.Post
  require Logger
  require Ecto.Query

  def list(conn, _params) do
    posts = Squeak.Posts.Post
    |> Ecto.Query.order_by([a], desc: a.inserted_at)
    |> Squeak.Repo.all()
    render(conn, "list.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Post.changeset(%Post{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    user = Pow.Plug.current_user(conn)
    date = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    params = post_params
    |> Map.put("user_id", user.id)
    |> Map.put("updated_at", date)
    |> Map.put("inserted_at", date)
    changeset = Post.changeset(%Post{}, params)

    if changeset.valid? do
      Squeak.Repo.insert(changeset)

      flash_message = if params["draft"] == "true" do
        "Draft post has been saved."
      else
        "Post has been published"
      end

      conn
      |> put_flash(:info, flash_message)
      |> redirect(to: SqueakWeb.Router.Helpers.admin_path(conn, :index))
    else
      render(conn, "new.html", changeset: %{changeset | action: :insert})
    end
  end

  def edit(conn, %{"id" => post_id}) do
    post = Squeak.Repo.get(Squeak.Posts.Post, post_id)

    if is_nil(post) do
      conn
        |> put_flash(:error, "Post not found")
        |> redirect(to: SqueakWeb.Router.Helpers.admin_path(conn, :index))
    end

    changeset = Post.changeset(post, %{})

    render(conn, "edit.html", changeset: changeset, post_id: post_id)
  end

  def update(conn, %{"post" => post_params, "id" => post_id}) do
    post = Squeak.Repo.get(Squeak.Posts.Post, post_id)
    |> Squeak.Repo.preload(:user)

    if is_nil(post) do
      conn
        |> put_flash(:error, "Post not found")
        |> redirect(to: SqueakWeb.Router.Helpers.admin_path(conn, :index))
    end

    date = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    params = post_params
    |> Map.put("updated_at", date)
    changeset = Post.changeset(post, params)

    if changeset.valid? do
      Squeak.Repo.update(changeset)

      flash_message = if params["draft"] == "true" do
        "Draft post has been updated."
      else
        "Post has been updated"
      end

      conn
      |> put_flash(:info, flash_message)
      |> redirect(to: SqueakWeb.Router.Helpers.admin_path(conn, :index))
    else
      render(conn, "edit.html", changeset: %{changeset | action: :insert}, post_id: post_id)
    end
  end

  def delete(conn, %{"id" => post_id}) do
    post = Squeak.Repo.get(Squeak.Posts.Post, post_id)

    if is_nil(post) do
      conn
        |> put_flash(:error, "Post not found")
        |> redirect(to: SqueakWeb.Router.Helpers.admin_path(conn, :index))
    end

    case Squeak.Repo.delete post do
      {:ok, _struct} -> conn
        |> put_flash(:info, "Post deleted")
        |> redirect(to: SqueakWeb.Router.Helpers.admin_path(conn, :index))
      {:error, _changeset} -> conn
        |> put_flash(:error, "Cannot delete post")
        |> redirect(to: SqueakWeb.Router.Helpers.admin_path(conn, :index))
    end
  end

end
