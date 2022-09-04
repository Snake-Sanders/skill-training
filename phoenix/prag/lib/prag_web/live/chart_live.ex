defmodule PragWeb.ChartLive do
  use PragWeb, :live_view

  def mount(_params, _session, socket) do
    labels = 1..12 |> Enum.to_list()
    values = Enum.map(labels, fn _ -> get_reading() end)

    {:ok,
     assign(socket,
       chart_data: %{labels: labels, values: values}
     )}
  end

  def render(assigns) do
    ~H"""
    <div id="charting">
    <h1>Blood Sugar</h1>
    <canvas id="chart-canvas"
            phx-hook="LineChart"
            data-chart-data={Jason.encode!(@chart_data)}></canvas>
    </div>
    """
  end
  defp get_reading() do
    Enum.random(70..180)
  end
end
