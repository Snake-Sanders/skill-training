defmodule PragWeb.ServersLive do
  use PragWeb, :live_view
  alias Prag.Servers
  alias Prag.Servers.Server

  def mount(_param, _session, socket) do
    servers = Servers.list_servers()

    socket =
      assign(socket,
        servers: servers,
        selected_server: hd(servers),
        changeset: Servers.change_server(%Server{})
      )

    {:ok, socket, temporary_assigns: [servers: []]}
  end

  # `handle_params` without parameters is called after `mount()`. mount does not porvide
  # any id, therefore the default case will show the first server selected
  # (selected_server is set in mount).
  # `handle_params` is also called when clicking on a `patch link` with the desired
  # server id to be displayed.
  def handle_params(%{"id" => id} = _params, _url, socket) do
    server =
      String.to_integer(id)
      |> Servers.get_server!()

    socket =
      assign(socket,
        selected_server: server,
        page_title: "#{server.name}"
      )

    {:noreply, socket}
  end

  def handle_params(%{"name" => name}, _url, socket) do
    server = Servers.get_server_by_name(name)

    socket =
      assign(socket,
        selected_server: server,
        page_title: "#{server.name}"
      )

    {:noreply, socket}
  end

  # handles the url that does not have params
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
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

    IO.puts("handling save #{inspect(attrs)}")

    case Servers.create_server(attrs) do
      {:ok, server} ->
        IO.puts("added into DB #{inspect(server)}")

        socket =
          socket
          |> update(:servers, fn servers -> [server | servers] end)
          |> assign(selected_server: server, page_title: server.name)
          |> push_patch(to: Routes.live_path(socket, __MODULE__))

        IO.puts("Socket is; #{inspect(socket)}")
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("\n\nfailed saving entry #{inspect(changeset)}")
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
