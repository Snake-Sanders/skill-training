defmodule PragWeb.ServerComponent do
  use PragWeb, :live_component

  alias Prag.Servers

  def render(assigns) do
    ~H"""
    <div class="card">
      <%= if is_nil(@selected_server) do %>
        <p>No server selected</p>
      <% else %>
        <div class="header">
          <h2><%= @selected_server.name %></h2>
          <button class={@selected_server.status}
                  href="#"
                  phx-click="toggle-status"
                  phx-target={@myself}
                  phx-value-id={@selected_server.id}
                  phx_disable_with="Saving...">
            <%= @selected_server.status %>
          </button>
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
      <% end %>
    </div>
    """
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    server = Servers.get_server!(id)
    new_status = if server.status == "up", do: "down", else: "up"

    {:ok, _server} = Servers.update_server(server, %{status: new_status})

    {:noreply, socket}
  end
end
