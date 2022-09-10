defmodule PragWeb.ModalComponent do
  use PragWeb, :live_component

  # displays the modal and the close x button top corner
  # the content is rendered by the passed arg live_component
  def render(assigns) do
    ~H"""
    <div class="phx-modal"
          phx-window-keydown="close"
          phx-key="escape"
          phx-capture-click="close"
          phx-target={@myself}
          >
      <div class="phx-modal-content" >
        <%= live_patch raw("&times;"),
                to: @return_to,
                class: "phx-modal-close" %>
        <.live_component module={@component}
                        id="get_modal_component"
                        component={@component}
                        opts={@opts} />
      </div>
    </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
