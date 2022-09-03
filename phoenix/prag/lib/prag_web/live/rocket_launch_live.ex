defmodule PragWeb.RocketLaunchLive do
  use PragWeb, :live_view

  def mount(_params, session, socket) do
    mission_status =
      if connected?(socket) do
        "We are GO for launch!"
      else
        "Not ready yet"
      end

    socket =
      socket
      |> assign_current_user(session)
      |> assign(
        mission_status: mission_status,
        connected: connected?(socket)
      )

    {:ok, socket}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
    <h1>Rocket launch</h1>
      <%= @mission_status %>
      <p>
      Conection:<%= @connected %>
      </p>
    </div>
    """
  end
end
