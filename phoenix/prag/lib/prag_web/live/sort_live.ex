defmodule PragWeb.SortLive do
  use PragWeb, :live_view
  alias Prag.Donations

  @permitted_sort_bys ~w(item quantity days_until_expires)
  @permitted_sort_orders ~w(asc desc)

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _url, socket) do
    sort_by =
      params
      |> param_or_first_permitted("sort_by", @permitted_sort_bys)
      |> String.to_atom()

    sort_order =
      params
      |> param_or_first_permitted("sort_order", @permitted_sort_orders)
      |> String.to_atom()

    page = param_to_integer(params["page"], 1)
    per_page = param_to_integer(params["per_page"], 5)

    paginate_options = %{page: page, per_page: per_page}
    sort_options = %{sort_by: sort_by, sort_order: sort_order}

    donations =
      Donations.list_donations(
        paginate: paginate_options,
        sort: sort_options
      )

    socket =
      assign(socket,
        options: Map.merge(paginate_options, sort_options),
        donations: donations
      )

    {:noreply, socket}
  end

  # `per-page` is the name attribute of the `select` HTML component
  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)

    # paginate_options = %{page: socket.assigns.options.page, per_page: per_page}

    # donations = Donations.list_donations(paginate: paginate_options)

    # socket =
    #   assign(socket,
    #     options: paginate_options,
    #     donations: donations
    #   )

    # `push_patch` is to send to the client the new url since per_page is shown in the it.
    # Before `push_patch` is invoked first it calls handle_params, which already parses
    # the `page` and `per_page` and store them into `assigns`
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            page: socket.assigns.options.page,
            per_page: per_page,
            sort_by: socket.assigns.options.sort_by,
            sort_order: socket.assigns.options.sort_order
          )
      )

    {:noreply, socket}
  end

  defp expires_class(donation) do
    if Donations.almost_expired?(donation), do: "stale", else: "fresh"
  end

  defp pagination_link(socket, text, page, options, class) do
    live_patch(text,
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
      if sort_by == options.sort_by do
        text <> get_emoji(options.sort_order)
      else
        text
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

  defp get_emoji(:asc), do: "????"
  defp get_emoji(:desc), do: "????"

  defp param_or_first_permitted(params, key, permitted) do
    value = params[key]
    if value in permitted, do: value, else: hd(permitted)
  end

  defp param_to_integer(nil, default_value), do: default_value

  defp param_to_integer(param, default_value)
       when is_binary(param) and is_integer(default_value) do

    case Integer.parse(param) do
      {number, _} -> number
      :error -> default_value
    end
  end
end
