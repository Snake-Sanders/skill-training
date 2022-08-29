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
        recent_activity: ""
      )

    {:ok, socket, temporary_assigns: [volunteers: []]}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    # this changes are reflected to the client with preprend event
    socket =
      socket
      |> update(:volunteers, fn volunteers -> [volunteer | volunteers] end)
      |> update_recent_activity(volunteer)

    {:noreply, socket}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    # this changes are reflected to the client with preprend event
    socket =
      socket
      |> update(:volunteers, fn volunteers -> [volunteer | volunteers] end)
      |> update_recent_activity(volunteer)

    {:noreply, socket}
  end

  defp update_recent_activity(socket, volunteer) do
    assign(socket, recent_activity: "#{volunteer.name} checked
                #{if volunteer.checked_out, do: "out", else: "in"}!")
  end
end
