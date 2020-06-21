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

    # plug SqueakWeb.Plugs.Assigns,
    #  registration_enabled: Squeak.States.Config.get(:registration)
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

  pipeline :wiki do
    plug :put_layout, {SqueakWeb.LayoutView, :wiki}
    plug SqueakWeb.Plugs.WikiPath
  end

  pipeline :preload_stuff do
    plug SqueakWeb.Plugs.PreloadTags
  end

  pipeline :upload do
    plug Majic.Plug, pool: Squeak.MajicPool, fix_extension: false
  end

  scope "/" do
    pipe_through [:browser, :preload_stuff]

    pow_session_routes()
    pow_extension_routes()
  end

  scope "/", Pow.Phoenix, as: "pow" do
    pipe_through [:browser, :preload_stuff]
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
    pipe_through [:browser, :preload_stuff]

    get "/", BlogController, :list, as: "index"
    get "/about", PageController, :about
    get "/blog.atom", BlogFeedController, :list
  end

  scope "/blog", SqueakWeb do
    pipe_through [:browser, :preload_stuff]

    get "/", BlogController, :list
    # Search
    get "/search", BlogController, :search
    # By user
    get "/u/:user_slug", BlogController, :list_by_user_slug
    get "/fu/:user_slug", BlogFeedController, :list_by_user_slug
    get "/u/:user_slug/:post_slug", BlogController, :show
    # By tag
    get "/t/:tag_slug", BlogController, :list_by_tag_slug
    get "/ft/:tag_slug", BlogFeedController, :list_by_tag_slug
  end

  scope "/wiki", SqueakWeb do
    pipe_through [:browser, :wiki]
    get "/", Redirector, to: "/wiki/p/start"
    get "/tree", WikiController, :tree
  end

  scope "/wiki/p", SqueakWeb do
    pipe_through [:browser, :wiki]
    get "/", Redirector, to: "/wiki/p/start"
    get "/*path", WikiController, :page
  end

  scope "/wiki/r", SqueakWeb do
    pipe_through [:browser, :wiki, :admin]
    get "/", Redirector, to: "/wiki/r/start"
    get "/*path", WikiEditController, :edit
    post "/*path", WikiEditController, :update
    put "/*path", WikiEditController, :delete
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

  scope "/admin/medias", SqueakWeb do
    pipe_through [:upload, :browser, :admin]

    get "/", AdminMediaController, :list
    get "/picker", AdminMediaController, :picker

    get "/new", AdminMediaController, :new
    post "/new", AdminMediaController, :create

    get "/edit/:id", AdminMediaController, :edit
    post "/edit/:id", AdminMediaController, :update
    put "/edit/:id", AdminMediaController, :update

    delete "/delete/:id", AdminMediaController, :delete

    get "/show/:id", AdminMediaController, :show
  end

  scope "/api/admin", SqueakWeb do
    pipe_through [:browser, :admin, :api]

    get "/autocomplete/tags", ApiAdminAutocompleteController, :tags
  end

  # Other scopes may use custom stacks.
  # scope "/api", SqueakWeb do
  #   pipe_through :api
  # end
end
