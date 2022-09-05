defmodule PragWeb.ChartLive do
  use PragWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(2000, self(), :update)

    end
    labels = 1..12 |> Enum.to_list()
    values = Enum.map(labels, fn _ -> get_reading() end)

    {:ok,
     assign(socket,
       chart_data: %{labels: labels, values: values},
       current_reading: List.last(labels)
     )}
  end

  def render(assigns) do
    ~H"""
    <div id="charting">
    <h1>Blood Sugar</h1>
    <canvas id="chart-canvas"
            phx-hook="LineChart"
            data-chart-data={Jason.encode!(@chart_data)}>
    </canvas>
    <div class="text-center">
    <button phx-click="get-reading">
      Get Reading
    </button>
    </div>

    </div>
    """
  end

  def handle_info(:update, socket) do
    {:noreply, add_point(socket)}
  end

  def handle_event("get-reading", _, socket) do

    {:noreply, add_point(socket)}
  end

  defp get_reading() do
    Enum.random(70..180)
  end

  defp add_point(socket) do
    socket = update(socket, :current_reading, &(&1 + 1))

    point = %{
      label: socket.assigns.current_reading,
      value: get_reading()
    }

    # sends to the client the new point
    push_event(socket, "new-point", point)
  end
end
