defmodule PragWeb.LoadingComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div>
      <%= if @loading do %>
        <div class="loader">
          Loading...
        </div>
      <% end %>
    </div>
    """
  end
end
