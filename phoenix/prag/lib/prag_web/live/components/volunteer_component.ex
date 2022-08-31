defmodule PragWeb.VolunteerComponent do
  use PragWeb, :live_component
  alias Prag.Volunteers

  def render(assigns) do
    ~H"""
    <div class={"volunteer #{if @volunteer.checked_out, do: "out"}"}
                id={"volunteer-#{Integer.to_string(@volunteer.id)}"} >
      <div class="name">
        <%= @volunteer.name %>
      </div>
      <div class="phone">
        <img src="images/phone.svg">
        <%= @volunteer.phone %>
      </div>
      <div class="status">
          <button phx-click="toggle-status"
                  phx-target={@myself}
                  phx-value-id={@volunteer.id}
                  phx-disable-with="Saving...">
            <%= if @volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button>
      </div>
    </div>
    """
  end

  # here we can capture the `id` because in the button we use phx-value-id
  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, _volunteer} = Volunteers.toggle_status_volunteer(volunteer)

    {:noreply, socket}
  end
end
