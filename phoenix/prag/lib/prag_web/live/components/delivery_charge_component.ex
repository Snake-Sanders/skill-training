defmodule PragWeb.DeliveryChargeComponent do
  use PragWeb, :live_component
  alias Prag.SandboxCalculator
  import Number.Currency

  def mount(socket) do
    {:ok, assign(socket, zip: nil, charge: nil)}
  end

  def render(assigns) do
    ~H"""
    <form phx-change="calc-delivery"
          phx-debounce="1000"
          phx-target={@myself}>
      <div class="field">
        <label for="zip">Zip Code:</label>
          <input type="text" name="zip" value={@zip} />
          <span class="unit"><%= number_to_currency(@charge) %></span>
      </div>
    </form>
    """
  end

  def handle_event("calc-delivery", %{"zip" => zip}, socket) do
    charge = SandboxCalculator.calculate_delivery_charge(zip)
    socket = assign(socket, charge: charge, zip: zip)

    send(self(), {:delivery_charge, charge})

    {:noreply, socket}
  end
end
