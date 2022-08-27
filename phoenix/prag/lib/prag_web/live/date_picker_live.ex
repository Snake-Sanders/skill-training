defmodule PragWeb.DatePickerLive do

  use PragWeb, :live_view

  def mount(_param, _session, socket) do
    socket =
      socket
      |> assign(date: "")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <input  id="date-picker-input" type="text"
            class="form-input" value={@date}
            placeholder="Pick a date"
            phx-hook="DatePicker">
    """
  end

  def handle_event("dates-picked", date, socket) do
    socket =
      assign(socket, date: date)
    {:noreply, socket}
  end
end
