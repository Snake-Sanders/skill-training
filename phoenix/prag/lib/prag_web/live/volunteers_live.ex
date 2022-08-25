defmodule PragWeb.VolunteersLive do
  use PragWeb, :live_view

  alias Prag.Volunteers
  alias Prag.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    socket =
      assign(socket,
        volunteers: volunteers,
        changeset: Volunteers.change_volunteer(%Volunteer{})
      )

    {:ok, socket, temporary_assigns: [ volunteers: []]}
  end

  def handle_event("save", %{"volunteer" => params}, socket) do
    # `create_volunteer` will try to insert a new item in the DB with the content of params
    case Volunteers.create_volunteer(params) do
      {:ok, volunteer} ->
        # when the item was inserted in the database:
        # updates the list of volunteers without having to render all the list again.
        socket = update(socket, :volunteers, fn volunteers -> [volunteer | volunteers] end)
        # now prepares for the next volunteer
        changeset = Volunteers.change_volunteer(%Volunteer{})
        socket = assign(socket, changeset: changeset)
        # to see the "Saving..." message in the button
        :timer.sleep(500)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        # when the item was not inserted in the database:
        # the current form is updated with the previous values so they are not lost.
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end
end
