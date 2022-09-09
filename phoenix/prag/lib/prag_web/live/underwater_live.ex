defmodule PragWeb.UnderwaterLive do
  use PragWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, :show_modal, false)

    {:ok, socket}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1>Earth Is Super Watery</h1>
    <div id="underwater">
    <button phx-click="toggle-modal">
    🤿 Look Underwater 👀
    </button>

    <%= if @show_modal do %>
      <.live_component module={PragWeb.ModalComponent}
                       id="modal"
                       component={PragWeb.CreaturesComponent}/>
    <% end %>
    </div>
    """
  end

  def handle_event("toggle-modal", _, socket) do
    {:noreply, update(socket, :show_modal, &(!& 1))}
  end
end
