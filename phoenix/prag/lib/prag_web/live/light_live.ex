defmodule PragWeb.LightLive do
  use PragWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10, meter_color: 3000)
    {:ok, socket}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div role="progressbar" class="meter">
        <span style={"width: #{@brightness}%; background-color: #{temp_color(@meter_color)}"} >
          <%= @brightness %>%
        </span>
      </div>

      <button phx-click="off">
        <img src="images/light-off.svg">
        <span class="sr-only">Off</span>
      </button>

      <button phx-click="down">
        <img src="images/down.svg">
        <span class="sr-only">Down</span>
      </button>

      <button phx-click="up">
        <img src="images/up.svg">
        <span class="sr-only">Up</span>
      </button>

      <button phx-click="on">
        <img src="images/light-on.svg">
        <span class="sr-only">On</span>
      </button>

      <button phx-click="random">
        <span>Light Me up!</span>
      </button>

      <form phx-change="power">
        <input type="range" name="power-level" min="0" max="100" value={"#{@brightness}"}/>
      </form>

      <div class="color-temp">
        <form phx-change="color-temp">
          <%= for temperature <- temp_list() do %>
            <%= temp_ratio_button(temp_code: temperature, checked: (@meter_color == temperature)) %>
          <% end %>
        </form>
      </div>
    </div>
    """
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, :brightness, 100)
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &max(&1 - 10, 0))
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, &min(&1 + 10, 100))
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
    socket = assign(socket, :brightness, power)
    {:noreply, socket}
  end

  @doc """
  to match uses the name of the radio input component and capture its value
  <input type="radio" id="123" name="radio-temp" value="4000" />
  matches -> value = "4000"
  """
  def handle_event("color-temp", %{"radio-temp" => value}, socket) do
    temp_color = String.to_integer(value)
    socket = assign(socket, :meter_color, temp_color)
    {:noreply, socket}
  end

  defp temp_color(3000), do: "#F1C40D"
  defp temp_color(4000), do: "#FEFF66"
  defp temp_color(5000), do: "#99CCFF"

  defp temp_list(), do: [3000, 4000, 5000]

  defp temp_ratio_button(assigns) do
    # Assuming form contains a User schema
    # radio_button(form, :role, "admin")
    # => <input id="user_role_admin" name="user[role]" type="radio" value="admin">
    assigns = Enum.into(assigns, %{})

    ~H"""
    <input type="radio" id={"#{@temp_code}"} name="radio-temp" value={"#{@temp_code}"} checked={@checked} />
    <label for={@temp_code}><%= @temp_code %></label>
    """
  end
end
