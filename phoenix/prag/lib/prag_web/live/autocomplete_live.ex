defmodule PragWeb.AutocompleteLive do
  use PragWeb, :live_view
  alias Prag.Stores
  alias Prag.Cities

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        zip: "",
        city: "",
        stores: [],
        matches: [],
        loading: false
      )

    {:ok, socket, temporary_assigns: [stores: []]}
  end

  def render(assigns) do
    ~H"""
    <h1>Find a Store</h1>
    <div id="search">

      <form phx-submit="zip-search">
        <input type="text" name="zip" value={"#{@zip}"}
                placeholder="Zip Code"
                autofocus autocomplete="off"
                readonly={@loading} />

        <button type="submit">
          <img src="images/search.svg">
        </button>
      </form>

      <form phx-submit="city-search" phx-change="suggest-city">
        <input type="text" name="city" value={"#{@city}"}
                placeholder="City"
                autocomplete="off"
                list="matches"
                phx-debounce="800"
                readonly={@loading} />

        <button type="submit">
          <img src="images/search.svg">
        </button>
      </form>

      <datalist id="matches">
          <%= for match <- @matches do %>
              <option value={match}>
                  <%= match %>
              </option>
          <% end %>
      </datalist>

      <%= if @loading do %>
      <div class="loader">
        Loading...
      </div>
      <% end %>

      <div class="stores">
        <ul>
          <%= for store <- @stores do %>
            <li>
              <div class="first-line">
                <div class="name">
                  <%= store.name %>
                </div>
                <div class="status">
                  <%= if store.open do %>
                    <span class="open">Open</span>
                  <% else %>
                    <span class="closed">Closed</span>
                  <% end %>
                </div>
              </div>
              <div class="second-line">
                <div class="street">
                  <img src="images/location.svg">
                  <%= store.street %>
                </div>
                <div class="phone_number">
                  <img src="images/phone.svg">
                  <%= store.phone_number %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("zip-search", %{"zip" => zip}, socket) do
    # the search is performed separately
    # after the loading status is set
    send(self(), {:run_zip_search, zip})

    # here we just set the loading status
    socket =
      assign(socket,
        zip: zip,
        stores: [],
        loading: true
      )

    {:noreply, socket}
  end

  @doc """
  Returns a list of cities that start with the prefix
  """
  def handle_event("suggest-city", %{"city" => prefix}, socket) do
    suggestion = Cities.suggest(prefix)
    socket = assign(socket, matches: suggestion, city: prefix)
    {:noreply, socket}
  end

  # Enables the laoding event and triggers the search by sending a message to itself
  def handle_event("city-search", %{"city" => city}, socket) do
    send(self(), {:run_city_search, city})
    socket = assign(socket, cities: [], loading: true)

    {:noreply, socket}
  end

  def handle_info({:run_zip_search, zip}, socket) do
    socket =
      case Stores.search_by_zip(zip) do
        [] ->
          socket
          |> put_flash(:info, "No stores matching: #{zip}, try e.g.: 80204")
          |> assign(stores: [], loading: false)

        stores ->
          socket
          |> clear_flash()
          |> assign(stores: stores, loading: false)
      end

    {:noreply, socket}
  end

  @doc """
  runs the search of the city
  """
  def handle_info({:run_city_search, city}, socket) do
    socket =
      case Stores.search_by_city(city) do
        [] ->
          socket
          |> put_flash(:info, "No stores matching: #{city}, try e.g.: Amarillo")
          |> assign(stores: [], loading: false)

        stores ->
          socket
          |> clear_flash()
          |> assign(stores: stores, loading: false, city: city)
      end

    {:noreply, socket}
  end
end
