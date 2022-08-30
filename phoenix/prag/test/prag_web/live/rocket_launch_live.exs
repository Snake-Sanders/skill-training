defmodule PragWeb.RocketLaunchTest do
  use PragWeb.ConnCase, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  test "indicates ready for launch when connected", %{conn: conn} do
    # Disconnected:
    # The client sends a standard HTTP GET request.
    # On the server side, mount is called for the first time
    conn = get(conn, "/rocket-launch")

    refute html_response(conn, 200) =~ "We are GO for launch!"

    # Connected:
    # The client now connects to the server websocket.
    # On the server side, mount is called for the second time
    {:ok, view, _html} = live(conn)
    assert render(view) =~ "We are GO for launch!"
  end
end
