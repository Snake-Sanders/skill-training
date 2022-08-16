defmodule PragWeb.LicenseLive do
  use PragWeb, :live_view

  alias Prag.Licenses

  import Number.Currency

  def mount(_pramas, _session, socket) do
    socket = assign(socket, seats: 3, amount: Licenses.calculate(3))
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Team License</h1>
    <div id="license">
      <div class="card">
        <div class="content">
          <div class="seats">
            <img src="images/license.svg">
            <span>
              Your license is currently for
              <strong><%= @seats %></strong> seats.
            </span>
          </div>
          <form phx-change="update">
            <input type="range" min="1" max="10"
          name="seats" value={"#{@seats}"} />
          </form>
          <div class="amount">
            <%= number_to_currency(@amount) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  the second parameter is a map with information about the page
  `seats` is the name of the form.
  """
  def handle_event("update", %{"seats" => seats}, socket) do
    seats = String.to_integer(seats)

    socket =
      assign(socket,
        seats: seats,
        amount: Licenses.calculate(seats)
      )

    {:noreply, socket}
  end
end
