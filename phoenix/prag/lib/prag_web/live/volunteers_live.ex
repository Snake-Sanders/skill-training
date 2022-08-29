defmodule PragWeb.VolunteersLive do
  use PragWeb, :live_view

  alias Prag.Volunteers
  alias Prag.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    if connected?(socket), do: Volunteers.subscribe()

    volunteers = Volunteers.list_volunteers()

    socket =
      assign(socket,
        volunteers: volunteers,
        changeset: Volunteers.change_volunteer(%Volunteer{}),
        recent_activity: ""
      )

    {:ok, socket, temporary_assigns: [volunteers: []]}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    # this changes are reflected to the client with preprend event
    socket = update(socket, :volunteers, fn volunteers -> [volunteer | volunteers] end)

    {:noreply, socket}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    # this changes are reflected to the client with preprend event
    socket = update(socket, :volunteers, fn volunteers -> [volunteer | volunteers] end)

    socket = assign(socket, recent_activity: "#{volunteer.name} checked
                    #{if volunteer.checked_out, do: "out", else: "in"}!")

    {:noreply, socket}
  end
end
