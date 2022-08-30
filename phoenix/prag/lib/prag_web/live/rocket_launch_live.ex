defmodule PragWeb.RocketLaunchLive do
  use PragWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        assign(socket, mission_status: "We are GO for launch!")
      else
        assign(socket, mission_status: "Not ready yet")
      end

    socket =
      socket
      |> assign(connected: connected?(socket))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= @mission_status %>
      Conection:<%= @connected %>
    </div>
    """
  end
end
