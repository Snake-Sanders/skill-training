defmodule PragWeb.LightLive do
  use PragWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10, power_level: 10 )
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%"}>
          <%= @brightness %>%
        </span>
      </div>

      <button phx-click="off">
        <img src="images/light-off.svg">
      </button>

      <button phx-click="down">
        <img src="images/down.svg">
      </button>

      <button phx-click="up">
        <img src="images/up.svg">
      </button>

      <button phx-click="on">
        <img src="images/light-on.svg">
      </button>

      <button phx-click="random">
        <span>Light Me Up!</span>
      </button>

      <form phx-change="power">
        <input type="range" name="power-level" min="0" max="100" value={"#{@brightness}"}/>
      </form>
    </div>
    """
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, :brightness, 100)
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &max((&1 - 10 ), 0))
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, &min((&1 + 10 ),100))
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, :brightness, 0)
    {:noreply, socket}
  end

  def handle_event("random", _, socket) do
    socket = assign(socket, :brightness, Enum.random(0..100))
    {:noreply, socket}
  end

  def handle_event("power", %{"power-level" => power}, socket) do
    power = String.to_integer(power)
    socket = assign(socket, :brightness, power )
    {:noreply, socket}
  end
end
