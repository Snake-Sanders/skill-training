defmodule PragWeb.UnderwaterLive do
  use PragWeb, :live_view
  import Phoenix.LiveView.Helpers

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Earth Is Super Watery</h1>
      <div id="underwater">
        <%= live_patch "🤿 Look Underwater 👀",
            to: Routes.underwater_path(@socket, :show_modal),
            class: "button" %>

        <%= if @live_action == :show_modal do %>
          <%= live_modal(@socket,
                        PragWeb.CreaturesComponent,
                        return_to: Routes.live_path(@socket, __MODULE__ ),
                        title: "Sea Creatures") %>
        <% end %>
      </div>

      <div id="comment" class="mt-24">
        <p class="font-bold">The modal component view should close when:</p>
        <ul class="list-disc" >
          <li>Click on the button "I'm outta air!"</li>
          <li>Click on the `X` on the top-right corner.</li>
          <li>Pressing Escape.</li>
          <li>Click outside the modal view.</li>
        </ul>
      </div>

    </div>
    """
  end

end
