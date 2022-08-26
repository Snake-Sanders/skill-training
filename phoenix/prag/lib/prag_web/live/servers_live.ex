defmodule PragWeb.ServersLive do
  use PragWeb, :live_view
  alias Prag.Servers
  alias Prag.Servers.Server

  def mount(_param, _session, socket) do
    servers = Servers.list_servers()

    socket = assign(socket, servers: servers)

    {:ok, socket}
  end

  # `handle_params` without parameters is called after `mount()`. mount does not porvide
  # any name, therefore the default case will show the first server selected
  # (selected_server is set in mount).

  def handle_params(%{"name" => name}, _url, socket) do
    server = Servers.get_server_by_name(name)

    socket =
      assign(socket,
        selected_server: server,
        page_title: server.name
      )

    {:noreply, socket}
  end

  # handles the url that does not have params
  # This "handle_params" clause needs to assign socket data
  # based on whether the action is "new" or not.
  def handle_params(_params, _url, socket) do
    if socket.assigns.live_action == :new do
      # The live_action is "new", so the form is being
      # displayed. Therefore, assign an empty changeset
      # for the form. Also don't show the selected
      # server in the sidebar which would be confusing.
      changeset = Servers.change_server(%Server{})

      socket =
        assign(socket,
          selected_server: nil,
          changeset: changeset
        )

      {:noreply, socket}
    else
      # The live_action is NOT "new", so the form
      # is NOT being displayed. Therefore, don't assign
      # an empty changeset. Instead, just select the
      # first server in list. This previously happened
      # in "mount", but since "handle_params" is always
      # invoked after "mount", we decided to select the
      # default server here instead of in "mount".
      socket =
        assign(socket, selected_server: hd(socket.assigns.servers))

      {:noreply, socket}
    end
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
          |> update(:servers, fn servers -> [server | servers] end)
          |> push_patch(to: Routes.live_path(socket, __MODULE__, id: server.id))

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)

        {:noreply, socket}
    end
  end

  defp link_body(server, "name") do
    assigns = %{name: server.name, status: server.status}

    ~H"""
    <span class={"status #{@status}"}></span>
    <img src="/images/server.svg">
    <%= @name %>
    """
  end
end
