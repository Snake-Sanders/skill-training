defmodule PragWeb.SearchLive do
  use PragWeb, :live_view
  alias Prag.Stores

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        zip: "",
        stores: [],
        loading: false
      )

    {:ok, socket, temporary_assigns: [stores: []]}
  end

  def render(assigns) do
    ~H"""
    <h1>Find a Store</h1>
    <div id="search">

      <form id="zip-search" phx-submit="zip-search">
        <input type="text" name="zip" value={"#{@zip}"}
                placeholder="Zip Code"
                autofocus autocomplete="off"
                readonly={@loading} />

        <button type="submit">
          <img src="images/search.svg">
        </button>
      </form>

      <PragWeb.LoadingComponent.render loading={@loading}/>

      <div class="stores">
        <ul>
          <%= for store <- @stores do %>
            <li id={"store-#{store.id}"}>
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

      :timer.sleep(1000)

    {:noreply, socket}
  end
end
