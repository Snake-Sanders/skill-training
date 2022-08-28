defmodule PragWeb.QuoteComponent do
  use Phoenix.Component

  import Number.Currency

  @moduledoc """
  Stateless component now are called `Function component`
  and no longer has mount, it is just a funtion that renders HEEx
  """

  # {#{ if is_nil(@weight), do: :hidden} }
  def quote(assigns) do
    assigns = assign_new(assigns, :hrs_until_expires, fn -> 24 end)

    ~H"""
    <div class={" #{ if is_nil(@weight), do: "hidden" } text-center p-6 border-4 border-dashed border-indigo-600"}

      >
      <h2 class="text-2xl mb-2">
      Our best deal
      </h2>

      <h3 class="text-xl font-semibold text-indigo-600">
        <%= @weight %> pounds of <%= @material %>
        for <%= number_to_currency(@price) %>
        plus <%= number_to_currency(@charge)%> delivery
      </h3>
      <div class="text-gray-600">
        expires in <%= @hrs_until_expires %> hours
      </div>
    </div>
    """
  end
end
