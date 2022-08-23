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

    paginate_options = %{page: page, per_page: per_page}

    sort_by = (params["sort_by"] || "id") |> String.to_atom()
    sort_order = (params["sort_order"] || "asc") |> String.to_atom()

    sort_options = %{sort_by: sort_by, sort_order: sort_order}

    options = [paginate: paginate_options, sort: sort_options]

    vehicles = Vehicles.list_vehicles(options)

    socket =
      assign(socket,
        options: Map.merge(paginate_options, sort_options),
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
            per_page: per_page,
            sort_order: socket.assigns.options.sort_order,
            sort_by: socket.assigns.options.sort_by
          )
      )

    {:noreply, socket}
  end

  defp pagination_link(socket, name, page, options, class) do
    live_patch(name,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          page: page,
          per_page: options.per_page,
          sort_by: options.sort_by,
          sort_order: options.sort_order
        ),
      class: class
    )
  end

  defp sort_link(socket, text, sort_by, options) do
    text =
      case options do
        %{sort_by: ^sort_by, sort_order: sort_order} -> text <> get_emoji(sort_order)
        %{sort_by: _, sort_order: _} -> text
      end

    live_patch(text,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          sort_by: sort_by,
          sort_order: toggle_sort_order(options.sort_order),
          page: options.page,
          per_page: options.per_page
        )
    )
  end

  defp toggle_sort_order(:asc), do: :desc
  defp toggle_sort_order(:desc), do: :asc

  defp get_emoji(:asc), do: "👆"
  defp get_emoji(:desc), do: "👇"
end
