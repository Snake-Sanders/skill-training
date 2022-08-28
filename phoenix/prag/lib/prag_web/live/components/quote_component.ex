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
      </div>
    </div>
    """
  end
end
