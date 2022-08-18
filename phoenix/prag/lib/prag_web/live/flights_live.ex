defmodule PragWeb.FlightsLive do
  use PragWeb, :live_view

  alias Prag.Flights
  alias Prag.Airports

  def mount(_param, _session, socket) do
    socket =
      assign(socket,
        # flight number
        number: "",
        # selected airport
        airport: "",
        # list of flight
        flights: [],
        # list of flight suggested based on the prefix search
        matches: [],
        # flag to show that data is being processed on the server side
        loading: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Find a Flight</h1>
    <div id="search">
      <form phx-submit="search-flight-by-number">
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

      <form phx-submit="search-airport" phx-change="suggest-airport">
        <input type="text" name="airport"
               placeholder="Airport"
               autocomplete="off"
               value={@airport}
               list="matches"
               phx-debounce="500"
               readonly={@loading}
                />
        <button>
            <img src="images/search.svg" />
        </button>
      </form>

      <!-- dropdown suggestion for airports -->
      <datalist id="matches">
        <%= for match <- @matches do %>
        <option value={match}><%= match %></option>
        <% end %>
      </datalist>

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

  # handles event when clicking search flight button
  def handle_event(
        "search-flight-by-number",
        %{"flight-number" => flight_number} = _session,
        socket
      ) do
    send(self(), {"find_flight", flight_number})

    socket =
      assign(socket,
        number: flight_number,
        airport: "",
        flights: [],
        loading: true
      )

    {:noreply, socket}
  end

  # handles event when typing an airport name, this will suggest matching items
  def handle_event("suggest-airport", %{"airport" => prefix} = _session, socket) do
    socket = assign(socket, matches: Airports.suggest(prefix))
    {:noreply, socket}
  end

  # handles event when clicking search airport button
  def handle_event("search-airport", %{"airport" => airport} = _session, socket) do
    send(self(), {"find-airport", airport})

    socket =
      assign(socket,
        number: "",
        airport: airport,
        flights: [],
        loading: true
      )

    {:noreply, socket}
  end

  # runs internal message request for searching airports by their name
  def handle_info({"find-airport", airport}, socket) do
    socket =

      case Flights.search_by_airport(String.upcase(airport)) do
        [] ->
          socket
          |> put_flash(:info, "No flights found from the airport '#{airport}', try 'DEN'.")
          |> assign(flights: [], loading: false)

        result ->
          socket
          |> clear_flash()
          |> assign(loading: false, flights: Enum.map(result, &format_flight/1))
      end

    {:noreply, socket}
  end

  # runs internal message request for searching a flight by its number
  def handle_info({"find_flight", number}, socket) do
    socket =
      case Flights.search_by_number(number) do
        [] ->
          socket
          |> put_flash(:info, "No flights found for: #{number}, try e.g. 450.")
          |> assign(flights: [], loading: false)

        result ->
          socket
          |> clear_flash()
          |> assign(flights: Enum.map(result, &format_flight/1), loading: false)
      end

    {:noreply, socket}
  end

  defp format_flight(%{:departure_time => departure, :arrival_time => arrival} = flight) do
    flight
    |> Map.merge(%{
      departure_time: format_datetime(departure),
      arrival_time: format_datetime(arrival)
    })
  end

  # Check the DateTime formats
  # https://hexdocs.pm/timex/Timex.Format.DateTime.Formatters.Default.html
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
