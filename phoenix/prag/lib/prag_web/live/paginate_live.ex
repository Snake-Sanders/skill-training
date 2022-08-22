defmodule PragWeb.PaginateLive do
  use PragWeb, :live_view
  alias Prag.Donations

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "5")
    paginate_options = %{page: page, per_page: per_page}

    donations = Donations.list_donations(paginate: paginate_options)

    socket =
      assign(socket,
        options: paginate_options,
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
        to: Routes.live_path(
          socket,
          __MODULE__,
          page: socket.assigns.options.page,
          per_page: per_page
        )
      )

    {:noreply, socket}
  end

  defp expires_class(donation) do
    if Donations.almost_expired?(donation), do: "stale", else: "fresh"
  end

  defp pagination_link(socket, text, page, per_page, class) do
    live_patch(text,
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
