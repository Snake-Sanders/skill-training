defmodule PragWeb.VolunteerFormComponent do
  use PragWeb, :live_component
  alias Prag.Volunteers
  alias Prag.Volunteers.Volunteer

  def mount(socket) do
    changeset = Volunteers.change_volunteer(%Volunteer{})
    {:ok, assign(socket, changeset: changeset)}
  end

  def render(assigns) do
    ~H"""
    <div>
    <.form let={f} for={@changeset}
          id="create-volunteer"
          phx-submit="save"
          phx-change="validate"
          phx-target={@myself}
          >

      <div class="filed">
        <%= text_input f, :name,
                          placeholder: "Name",
                          autocomplete: "off",
                          phx_debounce: "blur"
        %>
        <%= error_tag f, :name %>
      </div>

      <div class="filed">
        <%= text_input f, :phone,
                          placeholder: "Phone",
                          autocomplete: "off",
                          phx_hook: "PhoneFormatter",
                          phx_debounce: "blur"
        %>
        <%= error_tag f, :phone %>
      </div>

      <div class="filed">
        <%= submit("Check In", phx_disable_with: "Saving...") %>
      </div>

    </.form>
    </div>
    """
  end

  def handle_event("save", %{"volunteer" => params}, socket) do
    # `create_volunteer` will try to insert a new item in the DB with the content of params
    case Volunteers.create_volunteer(params) do
      {:ok, _volunteer} ->
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
end
