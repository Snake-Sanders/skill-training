defmodule PragWeb.ServersLiveTest do
  use PragWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "clicking a server link shows its details", %{conn: conn} do
    server_1 = create_server("Apache_1")
    server_2 = create_server("Jenkins_2")

    {:ok, view, _html} = live(conn, "/servers")

    assert has_element?(view, "#selected-server")

    assert has_element?(view, "nav", server_1.name)
    assert has_element?(view, "nav", server_2.name)

    # open_browser(view)

    # the selected server will be the last inserted to the DB.
    # this checks that the main section displays the details of this server
    assert has_element?(view, "#selected-server", server_2.name)

    view
    |> element("nav a", server_1.name)
    |> render_click()

    assert has_element?(view, "#selected-server", server_1.name)

    # FIXME: if the server name contains spaces then the url is not valid.
    assert_patch(view, "/servers?#{get_server_url(server_1)}")
  end

  test "selects the server id in the URL", %{conn: conn} do
    _server_1 = create_server("Apache_1")
    server_2 = create_server("Jenkins_2")

    # Bookmarking feature:
    # tests that navigating to an url will show the right server
    {:ok, view, _html} = live(conn, "/servers?id=#{server_2.id}")

    assert has_element?(view, "#selected-server", server_2.name)
  end

  test "todo test", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/servers/new")

    valid_attrs = %{
      name: "MailServer",
      framework: "Elixir",
      size: 1.0,
      git_repo: "http://git.com"
    }

    view
    |> form("#server-form", %{server: valid_attrs})
    |> render_submit()

    assert has_element?(view, "nav", valid_attrs.name)
  end

  test "displays live validation", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/servers/new")

    valid_attrs = %{
      # `name` can't be blank
      name: "",
      framework: "Elixir",
      size: 1.0,
      git_repo: "http://git.com"
    }

    view
    |> form("#server-form", %{server: valid_attrs})
    |> render_change()

    # IO.inspect(render(view))
    assert has_element?(view, "#server-form", "can't be blank")
  end

  test "clicking a button toggles status", %{conn: conn} do
    server = create_server("Mail")
    _server_2 = create_server("Web")

    {:ok, view, _html} = live(conn, "/servers")

    status_button = "#server-#{server.id} a"

    view
    |> element(status_button)
    |> render_click()

    # turn down
    view
    |> element("button", "up")
    |> render_click()

    assert has_element?(view, "button", "down")

    # turn up
    view
    |> element("button", "down")
    |> render_click()

    assert has_element?(view, "button", "up")
  end

  test "receive real-time server updates", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/servers")

    external_volunteer = create_server("Data-Backup")

    assert has_element?(view, "nav", external_volunteer.name)
    # open_browser(view)
  end

  defp get_server_url(server) do
    "name=#{server.name}&id=#{server.id}"
  end

  defp create_server(name) do
    {:ok, server} =
      Prag.Servers.create_server(%{
        name: name,
        # these are irrelevant for tests:
        status: "up",
        deploy_count: 1,
        size: 1.0,
        framework: "framework",
        git_repo: "repo",
        last_commit_id: "id",
        last_commit_message: "message"
      })

    server
  end
end
