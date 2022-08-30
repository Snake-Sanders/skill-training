defmodule PragWeb.SalesDashboardLive do
  use PragWeb, :live_view

  alias Prag.Sales

  @doc """
  mount is invoked twice:
  1. When the HTTP request is received and the full page is sent back to the
    client.
  2. When the client establishes connection to the web socked on the Server.
  """
  def mount(_params, _session, socket) do
    # starts the periodic info event to refresh the page every 1 sec.
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    socket = assign_stats(socket)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Sales Dashboard</h1>
    <div id="dashboard">
      <div class="stats">
        <div class="stat">
          <span class="value">
            <%= @new_orders %>
          </span>
          <span class="name">
            New Orders
          </span>
        </div>
        <div id="sales-amount" class="stat">
          <span class="value">
            $<%= @sales_amount %>
          </span>
          <span class="name">
            Sales Amount
          </span>
        </div>
        <div class="stat">
          <span class="value">
            <%= @satisfaction %>%
          </span>
          <span class="name">
            Satisfaction
          </span>
        </div>
      </div>
      <button id="refresh" phx-click="refresh">
        <img src="images/refresh.svg">
        Refresh
      </button>
    </div>
    """
  end

  def handle_event("refresh", _, socket) do
    socket = assign_stats(socket)
    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    # When the state changes it renders automatically
    socket = assign_stats(socket)
    {:noreply, socket}
  end

  defp assign_stats(socket) do
    assign(socket,
      new_orders: Sales.new_orders(),
      sales_amount: Sales.sales_amount(),
      satisfaction: Sales.satisfaction()
    )
  end
end
