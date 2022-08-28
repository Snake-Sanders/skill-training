defmodule PragWeb.SandboxLive do
  use PragWeb, :live_view

  alias PragWeb.QuoteComponent
  alias PragWeb.SandboxCalculatorComponent

  def mount(_params, _session, socket) do
    {:ok, assign(socket, weight: nil, price: nil)}
  end

  def render(assigns) do
    ~H"""
    <h1>Build a sandbox</h1>

    <div id="sandbox">
      <.live_component module={SandboxCalculatorComponent} id="comp1" />

      <QuoteComponent.quote
          material="sand"
          weight={@weight}
          price={@price} />

    </div>
    """
  end

  def handle_info({:totals, %{weight: weight, price: price}}, socket) do
    socket = assign(socket, weight: weight, price: price)
    IO.puts("+++ LiveView assings:#{inspect(socket.assigns)}")
    {:noreply, socket}
  end
end
