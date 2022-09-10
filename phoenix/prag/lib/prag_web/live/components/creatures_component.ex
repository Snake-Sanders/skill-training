defmodule PragWeb.CreaturesComponent do
  use PragWeb, :live_component

  def render(assigns) do
    # the req params are under opts, these are given to assigns for easy access
    assigns = assign(assigns, assigns.opts)

    ~H"""
    <div>
      <h2><%= @title %></h2>
      <div class="creatures">
      🐙 🐳 🦑 🐡 🐚 🐋 🐟 🦈 🐠 🦀 🐬
      </div>
      <%= live_patch "I'm outta air!",
          to: @return_to, class: "button" %>
    </div>
    """
  end
end
