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
