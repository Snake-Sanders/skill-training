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

  def handle_event("save", %{"volunteer" => params}, socket) do
    # `create_volunteer` will try to insert a new item in the DB with the content of params
    case Volunteers.create_volunteer(params) do
      {:ok, volunteer} ->
        # when the item was inserted in the database:
        # updates the list of volunteers without having to render all the list again.
        # when volunteer is created there is a new event handled by handle_info
        # now prepares for the next volunteer
        changeset = Volunteers.change_volunteer(%Volunteer{})
        socket = assign(socket, changeset: changeset)
        # to see the "Saving..." message in the button

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        # when the item was not inserted in the database:
        # the current form is updated with the previous values so they are not lost.
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"volunteer" => attrs}, socket) do
    # In order to display any validation fields, it is required to indicate the action
    # of the changeset,
    changeset =
      %Volunteer{}
      |> Volunteers.change_volunteer(attrs)
      |> Map.put(:action, :insert)

    # updating the changeset in the socket will trigger a render
    socket = assign(socket, changeset: changeset)

    {:noreply, socket}
  end

  # here we can capture the `id` because in the buttom we use phx-value-id
  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, _volunteer} = Volunteers.toggle_status_volunteer(volunteer)

    {:noreply, socket}
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
