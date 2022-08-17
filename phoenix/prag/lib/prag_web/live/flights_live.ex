defmodule PragWeb.FlightsLive do
  use PragWeb, :live_view

  alias Prag.Flights

  def mount(_param, _session, socket) do
    socket =
      assign(socket,
        number: "",
        flights: [],
        loading: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Find a Flight</h1>
    <div id="search">
      <form phx-submit="search">
        <input type="text" name="flight-number"
                placeholder="Flight Number"
                autofocus autocomplete="off"
                value={@number}
                readonly={@loading}
               />
        <button type="submit" >
          <img src="images/search.svg" />
        </button>
      </form>

      <%= if @loading do %>
        <div class="loader">Loading...</div>
      <% end %>

      <div class="flights">
        <ul>
          <%= for flight <- @flights do %>
            <li>
              <div class="first-line">
                <div class="number">
                  Flight #<%= flight.number %>
                </div>
                <div class="origin-destination">
                  <img src="images/location.svg">
                  <%= flight.origin %> to
                  <%= flight.destination %>
                </div>
              </div>
              <div class="second-line">
                <div class="departs">
                  Departs: <%= flight.departure_time %>
                </div>
                <div class="arrives">
                  Arrives: <%= flight.arrival_time %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("search", %{"flight-number" => flight_number} = _session, socket) do
    send(self(), {"search_flight", flight_number})

    socket =
      assign(socket,
        flights: [],
        number: flight_number,
        loading: true
      )

    {:noreply, socket}
  end

  def handle_info({"search_flight", number}, socket) do
    socket =
      case Flights.search_by_number(number) do
        [] ->
          socket
          |> put_flash(:info, "No flights found for: #{number}, try e.g. 450.")
          |> assign(flights: [], loading: false, number: number)

        result ->
          formatted_flights =
            result
            |> Enum.map(&format_flight/1)

          socket
          |> clear_flash()
          |> assign(flights: formatted_flights, loading: false, number: number)
      end

    {:noreply, socket}
  end

  def format_flight(%{:departure_time => departure, :arrival_time => arrival} = flight) do
    flight
    |> Map.merge(%{
      departure_time: format_datetime(departure),
      arrival_time: format_datetime(arrival)
    })
  end

  @doc """
  Check the DateTime formats
  https://hexdocs.pm/timex/Timex.Format.DateTime.Formatters.Default.html
  """
  @spec format_datetime(DateTime.t()) :: String.t()
  defp format_datetime(datetime) do
    # This will print: Aug at 18 13:06
    Timex.format!(datetime, "{Mshort} at {0D} {h24}:{m}")

    # This will print: "Thursday 2022-08-18 14:10"
    # Timex.format!(datetime, "{WDfull} {YYYY}-{0M}-{0D} {h24}:{m}")

    # This will print: Aug 17 at 14:32
    # Timex.format!(time, "%b %d at %H:%M", :strftime)
  end
end
