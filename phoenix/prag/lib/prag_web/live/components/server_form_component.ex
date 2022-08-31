defmodule PragWeb.ServerFormComponent do
  use PragWeb, :live_component
  alias Prag.Servers
  alias Prag.Servers.Server

  def mount(socket) do
    changeset = Servers.change_server(%Server{})

    socket = assign(socket, changeset: changeset)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form let={f} for={@changeset}
              phx-submit="save"
              phx-target={@myself}
              phx-change="validate"
              id="server-form">

          <div class="field">
            <%= label f, :name %>
            <%= text_input f, :name, phx_debounce: "blur" %>
            <%= error_tag f, :name %>
          </div>

          <div class="field">
            <%= label f, :framework %>
            <%= text_input f, :framework, phx_debounce: "blur" %>
            <%= error_tag f, :framework %>
          </div>

          <div class="field">
            <%= label f, :size, "Size (MB)" %>
            <%= number_input f, :size, phx_debounce: "blur" %>
            <%= error_tag f, :size %>
          </div>

          <div class="field">
            <%= label f, :git_repo, "Git Repo" %>
            <%= text_input f, :git_repo, phx_debounce: "blur" %>
            <%= error_tag f, :git_repo %>
          </div>

          <%= submit("Save", phx_disable_with: "Saving...") %>
          <%= live_patch "Cancel",
            to: Routes.live_path(@socket, PragWeb.ServersLive),
            class: "cancel"
          %>
      </.form>
    </div>
    """
  end

  # the data from the form arrives as a Map with the format, as in the example below:
  # %{"server" =>
  #    %{ "framework" => "Java",
  #       "git_repo" => "http/git.com",
  #       "name" => "apache",
  #       "size" => "299"
  #     }
  # }
  # Question: Does the main key is called "server" because the form is create based on the changeset
  # which is %Server{}
  def handle_event("save", %{"server" => attrs}, socket) do
    # retrieve the data from the Server Form
    # store it in the DB and append it to the list on the client side.
    # if it fails storing into DB it returns the changeset so the form data is not lost.
    case Servers.create_server(attrs) do
      {:ok, server} ->
        socket =
          socket
          # this "redirection" will be handled by handle_param, be sure that matches the right clause.
          # for this we need the name, otherwise will take the default clause where the selected_server is nil.
          |> push_patch(
            to: Routes.live_path(socket, PragWeb.ServersLive, id: server.id, name: server.name)
          )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("-- handle_event(save) failed storing in DB : #{inspect(self())}")
        socket = assign(socket, changeset: changeset)

        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"server" => attrs}, socket) do
    changeset =
      %Server{}
      |> Servers.change_server(attrs)
      |> Map.put(:action, :insert)

    socket = assign(socket, changeset: changeset)

    {:noreply, socket}
  end
end
