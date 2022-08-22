defmodule PragWeb.ServersLive do
  use PragWeb, :live_view
  alias Prag.Servers

  def mount(_param, _session, socket) do
    servers = Servers.list_servers()

    socket =
      assign(socket,
        servers: servers,
        selected_server: hd(servers)
      )

    {:ok, socket}
  end

  # `handle_params` without parameters is called after `mount()`. mount does not porvide
  # any id, therefore the default case will show the first server selected
  # (selected_server is set in mount).
  # `handle_params` is also called when clicking on a `patch link` with the desired
  # server id to be displayed.
  def handle_params(%{"id" => id} = _params, _url, socket) do
    server =
      String.to_integer(id)
      |> Servers.get_server!()

    socket =
      assign(socket,
        selected_server: server,
        page_title: "#{server.name}"
      )

    {:noreply, socket}
  end

  def handle_params(%{"name" => name}, _url, socket) do
    server = Servers.get_server_by_name(name)

    socket =
      assign(socket,
        selected_server: server,
        page_title: "#{server.name}"
      )

    {:noreply, socket}
  end

  # handles the url that does not have params
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <nav>
          <%= for server <- @servers do %>
            <div><p>
            <%= live_patch link_body(server, "name"),
                to: Routes.live_path(@socket, __MODULE__, name: server.name),
                replace: true,
                class: if server == @selected_server, do: "active"
            %>
            </p></div>
          <% end %>
        </nav>

      </div>
      <div class="main">
        <div class="wrapper">
          <div class="card">
            <div class="header">
              <h2><%= @selected_server.name %></h2>
              <span class={@selected_server.status}>
                <%= @selected_server.status %>
              </span>
            </div>
            <div class="body">
              <div class="row">
                <div class="deploys">
                  <img src="/images/deploy.svg">
                  <span>
                    <%= @selected_server.deploy_count %> deploys
                  </span>
                </div>
                <span>
                  <%= @selected_server.size %> MB
                </span>
                <span>
                  <%= @selected_server.framework %>
                </span>
              </div>
              <h3>Last Commit</h3>
              <div class="commit">
                <%= @selected_server.last_commit_id %>
              </div>
              <blockquote>
                <%= @selected_server.last_commit_message %>
              </blockquote>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp link_body(server, link_type) when link_type in ["id", "name"] do
    assigns = %{name: server.name, id: server.id}

    ~H"""
    <img src="/images/server.svg">
    <%= if link_type == "id", do: @id, else: @name %>
    """
  end
end
