defmodule PragWeb.FilterLive do
  use PragWeb, :live_view
  alias Prag.Boats

  def mount(_params, _session, socket) do
    socket = assign_defaults(socket)

    # to avoid that these boats are kept in memory we use 'temporary'
    # to delete them right after the template is rendered.
    {:ok, socket, temporary_assigns: [boats: []]}
  end

  defp assign_defaults(socket) do
    assign(socket,
      boats: Boats.list_boats(),
      type: "",
      prices: []
    )
  end

  def render(assigns) do
    ~H"""
    <h1>Daily Boat Rentals</h1>
    <div id="filter">
    <form phx-change="filter">
      <div class="filters">

        <select name="type">
          <%= options_for_select(type_options(), @type) %>
        </select>

        <div class="prices">
          <input type="hidden" name="prices[]" value="">
          <%= for price <- ["$", "$$", "$$$" ] do %>
            <%= price_checkbox(price: price, checked: price in @prices) %>
          <% end %>
        </div>

        <%= live_patch "Clear All",
            to: Routes.live_path(@socket, PragWeb.FilterLive, %{"action" => "clear_all"})
        %>
        <a href="#" phx-click="clear">Reset view</a>
      </div>
    </form>

    <span>Items: <%= length(@boats) %> </span>

    <div class="boats">
        <%= for boat <- @boats do %>
          <div class="card">
            <img src={boat.image}>
            <div class="content">
              <div class="model">
                <%= boat.model %>
              </div>
              <div class="details">
                <span class="price">
                  <%= boat.price %>
                </span>
                <span class="type">
                  <%= boat.type %>
                </span>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("filter", %{"type" => type, "prices" => prices}, socket) do
    params = [type: type, prices: prices]
    boats = Boats.list_boats(params)
    socket = assign(socket, params ++ [boats: boats])
    {:noreply, socket}
  end

  def handle_event("clear", _session, socket) do
    socket = assign_defaults(socket)
    {:noreply, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      case params do
        %{"action" => "clear_all"} -> assign_defaults(socket)
        _ -> socket
      end

    {:noreply, socket}
  end

  defp type_options() do
    [
      "All Types": "",
      Fishing: "fishing",
      Sporting: "sporting",
      Sailing: "sailing"
    ]
  end

  defp price_checkbox(assigns) do
    assigns = Enum.into(assigns, %{})

    ~H"""
    <input type="checkbox" id={@price}
          name="prices[]" value={@price}
          checked={@checked}
          />
    <label for={@price}><%= @price %></label>
    """
  end
end
