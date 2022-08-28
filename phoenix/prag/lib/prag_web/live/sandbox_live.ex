defmodule PragWeb.SandboxLive do
  use PragWeb, :live_view

  alias PragWeb.QuoteComponent
  alias PragWeb.SandboxCalculatorComponent
  alias PragWeb.DeliveryChargeComponent

  def mount(_params, _session, socket) do
    {:ok, assign(socket, weight: nil, price: nil, charge: nil)}
  end

  def render(assigns) do
    ~H"""
    <h1>Build a sandbox</h1>

    <div id="sandbox">
      <.live_component module={SandboxCalculatorComponent} id="comp1" />
      <%= if @weight do %>
        <.live_component module={DeliveryChargeComponent} id="comp2" />
        <QuoteComponent.quote
            material="sand"
            weight={@weight}
            price={@price}
            charge={@charge} />
      <% end %>
    </div>
    """
  end

  def handle_info({:totals, %{weight: weight, price: price}}, socket) do
    socket = assign(socket, weight: weight, price: price)
    IO.puts("+++ LiveView totals:#{inspect(socket.assigns)}")
    {:noreply, socket}
  end

  # def handle_info({:delivery, %{charge: charge}}, socket) do
  def handle_info({:delivery_charge, charge}, socket) do
    socket = assign(socket, :charge, charge )
    IO.inspect(socket, label: "yo")
    {:noreply, socket}
  end
end
