defmodule PragWeb.KeyEventsLive do
  use PragWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       images: Enum.map(0..18, &"juggling-#{&1}.jpg"),
       current: 0,
       is_playing: false
     )}
  end

  def render(assigns) do
    ~H"""
    <h1>Juggling Key Events</h1>
    <div id="key-events" phx-window-keyup="update">
      <img src={"/images/juggling/#{Enum.at(@images, @current)}"} alt="">
      <div class="status">
        <%= Enum.at(@images, @current) %>
        <input  type="number"
                value={@current}
                phx-keyup="set-current"
                phx-key="Enter" />
        <div>
          <%= if @is_playing, do: "Playing", else: "Pause" %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("update", %{"key" => "ArrowRight"}, socket) do
    {:noreply, assign(socket, :current, next(socket))}
  end

  def handle_event("update", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, assign(socket, :current, previous(socket))}
  end

  def handle_event("update", %{"key" => "k"}, socket) do
    is_playing = !socket.assigns.is_playing

    if is_playing do
      :timer.send_after(500, self(), :loop)
    end

    {:noreply, assign(socket, :is_playing, is_playing)}
  end

  def handle_event("update", %{"key" => key}, socket) do
    IO.inspect(key)
    {:noreply, socket}
  end

  def handle_event("set-current", %{"key" => "Enter", "value" => value}, socket) do
    {:noreply, assign(socket, :current, String.to_integer(value))}
  end

  def handle_info(:loop, socket) do
    if socket.assigns.is_playing do
      :timer.send_after(500, self(), :loop)
      {:noreply, assign(socket, :current, next(socket))}
    else
      {:noreply, socket}
    end
  end

  defp next(socket) do
    rem(
      socket.assigns.current + 1,
      Enum.count(socket.assigns.images)
    )
  end

  defp previous(socket) do
    rem(
      socket.assigns.current - 1 + Enum.count(socket.assigns.images),
      Enum.count(socket.assigns.images)
    )
  end
end
