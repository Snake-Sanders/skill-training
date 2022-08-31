defmodule PragWeb.SalesDashboardLiveTest do
  use PragWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  defp get_text_for_selector(html, selector) do
    html
    |> Floki.parse_document!()
    |> Floki.find(selector)
    |> Floki.text()
  end

  test "refreshes when refresh button is clicked", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/sales-dashboard")

    before_refresh = render(view)

    after_refresh =
      view
      |> element("#refresh")
      |> render_click()

    refute after_refresh =~ before_refresh
  end

  test "refreshes automatically every tick (I)", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/sales-dashboard")

    before_refresh = render(view)

    # instead of waiting 1 second to see the refresh we can just
    # send the :tick event
    send(view.pid, :tick)

    refute render(view) =~ before_refresh
  end

  test "refreshes automatically every tick (II)", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/sales-dashboard")

    # this test uses Floki

    assert view |> has_element?("#sales-amount")

    before_refresh =
      render(view)
      |> get_text_for_selector("#sales-amount")

    send(view.pid, :tick)

    after_refresh =
      render(view)
      |> get_text_for_selector("#sales-amount")

    refute before_refresh =~ after_refresh
  end
end
