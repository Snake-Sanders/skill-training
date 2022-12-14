defmodule PragWeb.Router do
  use PragWeb, :router

  import PragWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PragWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
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
    live "/sandbox", SandboxLive
    live "/chart", ChartLive
    live "/map", MapLive
    live "/key-events", KeyEventsLive
    live "/desks", DesksLive
    live "/underwater", UnderwaterLive
    live "/underwater/show", UnderwaterLive, :show_modal
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

  ## Authentication routes

  scope "/", PragWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    # this route also captures the call to Routes.user_registration_path(conn, :new)
    live "/users/register", RegisterLive, :new, as: :user_registration

    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", PragWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/topsecret", TopSecretLive
    live "/rocket-launch", RocketLaunchLive

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", PragWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end
