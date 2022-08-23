defmodule PragWeb.VehiclesLive do
  use PragWeb, :live_view

  alias Prag.Vehicles

  def mount(_params, _session, socket) do
    socket = assign(socket, total_vehicles: Vehicles.count_vehicles())
    {:ok, socket, temporary_assigns: [vehicles: []]}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "5")

    options = %{page: page, per_page: per_page}

    vehicles = Vehicles.list_vehicles(paginate: options)

    socket =
      assign(socket,
        options: options,
        vehicles: vehicles
      )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    # here the `per_page` value should be stored in the assigns, but since we call
    # push_patch, that function first calls handle_paramas, which already does that:

    # - converts strings `page` and `per_page` to integer
    # - creates the search criteria and retrieves the values from DB
    # - updates the values in assigns.

    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            page: socket.assigns.options.page,
            per_page: per_page
          )
      )

    {:noreply, socket}
  end

  defp pagination_link(socket, name, page, per_page, class) do
    live_patch(name,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          page: page,
          per_page: per_page
        ),
      class: class
    )
  end
end
