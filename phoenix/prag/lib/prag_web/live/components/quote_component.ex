defmodule PragWeb.QuoteComponent do
  use PragWeb, :live_component

  import Number.Currency

  @moduledoc """
  This is a stateless component
  first runs `mount`, then (optional) `update` and then `render`
  """
  def mount(socket) do

    {:ok, assign(socket, hrs_until_expires: 2)}
  end

  @doc """
  `update` gets called after `mount`
  `assigns` are all the parameters we passed to `live_component`
  `assigns` get merged in to the `socket`
  """
  def update(assigns, socket) do
    # this assignment gets executed automatically event if
    # `update` was not defined
    socket = assign(socket, assigns)

    socket =
      assign(socket, minutes: socket.assigns.hrs_until_expires * 60)
    {:ok, socket}
  end
  def render(assigns) do
    ~H"""
    <div class="text-center p-6 border-4 border-dashed border-indigo-600">
      <h2 class="text-2xl mb-2">
      Out best deal
      </h2>

      <h3 class="text-xl font-semibold text-indigo-600">
        <%= @weight %> pounds of <%= @material %>
        for <%= number_to_currency(@price) %>
      </h3>
      <div class="text-gray-600">
        expires in <%= @hrs_until_expires %> hours
        (<%= @minutes %> minutes)
      </div>
    </div>
    """
  end
end
