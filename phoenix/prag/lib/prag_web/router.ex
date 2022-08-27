defmodule PragWeb.Router do
  use PragWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PragWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PragWeb do
    pipe_through :browser

    get "/sales", SalesController, :index

    live "/", PageLive
    live "/light", LightLive
    live "/flights", FlightsLive
    live "/license", LicenseLive
    live "/sales-dashboard", SalesDashboardLive
    live "/search", SearchLive
    live "/autocomplete", AutocompleteLive
    live "/filter", FilterLive
    live "/git-repos", GitRepoLive
    live "/servers", ServersLive
    live "/servers/new", ServersLive, :new
    live "/servers/delete", ServersLive, :delete
    live "/paginate", PaginateLive
    live "/vehicles", VehiclesLive
    live "/sort", SortLive
    live "/volunteers", VolunteersLive
    live "/infinite-scroll", InfiniteScrollLive
    live "/datepicker", DatePickerLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", PragWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PragWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
