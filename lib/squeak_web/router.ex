defmodule SqueakWeb.Router do
  use SqueakWeb, :router
  use Pow.Phoenix.Router

  use Pow.Extension.Phoenix.Router,
    extensions: [PowResetPassword, PowEmailConfirmation]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug SqueakWeb.Plugs.Assigns,
      registration_enabled: Application.get_env(:squeak, :registration, false)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug SqueakWeb.Plugs.EnsureRole, :admin
    plug :put_layout, {SqueakWeb.LayoutView, :admin}
  end

  scope "/" do
    pipe_through :browser

    pow_session_routes()
    pow_extension_routes()
  end

  scope "/", Pow.Phoenix, as: "pow" do
    pipe_through [:browser]
    # TODO FIXME do something better
    actions =
      if Application.get_env(:squeak, :registration, false) do
        [:edit, :update, :delete, :new, :create]
      else
        [:edit, :update, :delete]
      end

    resources "/registration", RegistrationController, singleton: true, only: actions
  end

  scope "/", SqueakWeb do
    pipe_through :browser

    get "/", BlogController, :list, as: "index"
    get "/about", PageController, :about
  end

  scope "/blog", SqueakWeb do
    pipe_through :browser

    get "/", BlogController, :list
    get "/:user_slug", BlogController, :list_by_user_slug
    get "/:user_slug/:post_slug", BlogController, :show
  end

  scope "/wiki", SqueakWeb do
    pipe_through :browser
  end

  scope "/admin", SqueakWeb do
    pipe_through [:browser, :admin]

    get "/", AdminController, :index

    get "/posts", AdminPostController, :list

    get "/posts/new", AdminPostController, :new
    post "/posts/new", AdminPostController, :create

    get "/posts/:id/edit", AdminPostController, :edit
    post "/posts/:id/edit", AdminPostController, :update
    put "/posts/:id/edit", AdminPostController, :update

    delete "/posts/:id/delete", AdminPostController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", SqueakWeb do
  #   pipe_through :api
  # end
end
