defmodule PragWeb.InfiniteScrollLive do
  use PragWeb, :live_view
  alias Prag.PizzaOrders

  def mount(_params, _seesion, socket) do
    socket =
      socket
      |> assign(page: 1, per_page: 10)
      |> load_orders()

    {:ok, socket, temporary_assigns: [orders: []]}
  end

  defp load_orders(socket) do
    page = socket.assigns.page
    per_page = socket.assigns.per_page

    assign(socket,
      orders:
        PizzaOrders.list_pizza_orders(
          page: page,
          per_page: per_page
        )
    )
  end

  def render(assigns) do
    ~H"""
    <div id="infinite-scroll">
      <h1>Pizza Lovers Timeline</h1>
      <div id="orders" phx-update="append">
        <%= for order <- @orders do %>
          <div class="order" id={Integer.to_string(order.id)}>
            <div class="id">
              <%= order.id %>
            </div>
            <div>
              <div class="pizza">
                <%= order.pizza %>
              </div>
              <div>
                ordered by
                <span class="username">
                  <%= order.username %>
                </span>
              </div>
            </div>
          </div>
        <% end %>
      </div>

      <!-- phx-hook="InfiniteScroll"
          data-page-number={@page}>
      -->
      <div id="footer">
        <button class="loader"
                phx-click="load-more"
                phx-disable-with="loading...">
          Loading More...
        </button>
      </div>
    </div>
    """
  end

  def handle_event("load-more", _params, socket) do
    socket =
      socket
      |> update(:page, &(&1 + 1))
      |> load_orders()

    {:noreply, socket}
  end
end
