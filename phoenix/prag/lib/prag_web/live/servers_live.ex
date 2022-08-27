defmodule PragWeb.ServersLive do
  use PragWeb, :live_view
  alias Prag.Servers
  alias Prag.Servers.Server

  def mount(_param, _session, socket) do
    if connected?(socket), do: Servers.subscribe()

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
      IO.puts("-- handle_params(action :new) : #{inspect(self())}")

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
      IO.puts(
        "-- handle_params(action #{inspect(socket.assigns.live_action)}) : #{inspect(self())}"
      )

      # The live_action is NOT "new", so the form
      # is NOT being displayed. Therefore, don't assign
      # an empty changeset. Instead, just select the
      # first server in list. This previously happened
      # in "mount", but since "handle_params" is always
      # invoked after "mount", we decided to select the
      # default server here instead of in "mount".
      socket = assign(socket, selected_server: hd(socket.assigns.servers))

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
          # this "redirection" will be handled by handle_param, be sure that matches the right clause.
          # for this we need the name, otherwise will take the default clause where the selected_server is nil.
          |> push_patch(
            to: Routes.live_path(socket, __MODULE__, id: server.id, name: server.name)
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

  def handle_event("toggle-status", %{"id" => id}, socket) do
    server = Servers.get_server!(id)
    new_status = if server.status == "up", do: "down", else: "up"

    {:ok, _server} = Servers.update_server(server, %{status: new_status})

    {:noreply, socket}
  end

  def handle_info({:server_created, server}, socket) do
    IO.puts("-- handle_info(:server_created) #{server.name}: #{inspect(self())}")

    socket =
      socket
      |> update(:servers, fn servers -> [server | servers] end)

    {:noreply, socket}
  end

  def handle_info({:server_updated, server}, socket) do
    IO.puts("-- handle_info(:server_updated) #{server.name}: #{inspect(self())}")

    curr_selected = socket.assigns.selected_server
    update_selected = !is_nil(curr_selected) and curr_selected.id == server.id

    socket =
      socket
      # |> update(:servers, &Enum.map(&1, fn s -> if s.id == server.id, do: server, else: s end))
      |> update(:servers, &replace_server_by_id(&1, server))
      |> assign(selected_server: if(update_selected, do: server, else: curr_selected))

    {:noreply, socket}
  end

  defp link_body(server, "name") do
    assigns = %{name: server.name, status: server.status}

    ~H"""
    <span class={"status #{@status}"}></span>
    <img src="/images/server.svg">
    <%= @name %>
    """
  end

  # searches for the `new_server` in `servers` and replaces it with `new_server`
  defp replace_server_by_id(servers, new_server) do
    Enum.map(servers, fn server ->
      if server.id == new_server.id do
        new_server
      else
        server
      end
    end)
  end
end
