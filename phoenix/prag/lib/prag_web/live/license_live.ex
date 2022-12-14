defmodule PragWeb.LicenseLive do
  use PragWeb, :live_view

  alias Prag.Licenses

  import Number.Currency

  def mount(_pramas, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    expiration_time = Timex.shift(Timex.now(), hours: 1)

    socket =
      assign(
        socket,
        seats: 3,
        amount: Licenses.calculate(3),
        expiration_time: expiration_time,
        time_remaining: time_remaining(expiration_time)
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Team License</h1>
    <div id="license">
      <div class="card">
        <div class="content">
          <div id="seats" class="seats">
            <img src="images/license.svg">
            <span>
              Your license is currently for
              <strong><%= @seats %></strong> seats.
            </span>
          </div>
          <form id="update-seats" phx-change="update" phx-debounce="250">
            <input type="range" min="1" max="10"
          name="seats" value={"#{@seats}"} />
          </form>
          <div id="amount" class="amount">
            <%= number_to_currency(@amount) %>
          </div>
        </div>
      </div>
      <p class="m-4 font-semibold text-indigo-800">
        <%= if @time_remaining > 0 do %>
          <%= format_time(@time_remaining) %> left to save 20%
        <% else %>
          Expired!
        <% end %>
      </p>
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

  def handle_info(:tick, socket) do
    expiration_time = socket.assigns.expiration_time
    socket = assign(socket, :time_remaining, time_remaining(expiration_time))
    {:noreply, socket}
  end

  # returns seconds diff
  defp time_remaining(expiration_time) do
    DateTime.diff(expiration_time, Timex.now())
  end

  defp format_time(time) do
    time
    |> Timex.Duration.from_seconds()
    |> Timex.format_duration(:humanized)
  end
end
