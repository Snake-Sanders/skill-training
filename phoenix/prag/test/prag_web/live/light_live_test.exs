defmodule PragWeb.LightLiveTest do
  use PragWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "initial render", %{conn: conn} do
    # mount the live view
    # `html` is the rendered html after mount
    # `view` is a struct that contains the connected state
    # to get the html from the `view` struct we need to render it.
    {:ok, view, html} = live(conn, "/light")

    assert html =~ "Porch Light"
    assert render(view) =~ "Porch Light"
  end

  test "light events control ", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/light")

    # check if there is a 10% string somewere in the html
    assert render(view) =~ "10%"

    # the following tests send only an event and expect that
    # the light percentage changes but
    # they ommit checking if the button exist.
    assert render_click(view, :up) =~ "20%"
    assert render_click(view, :down) =~ "10%"
    assert render_click(view, :on) =~ "100%"
    assert render_click(view, :off) =~ "0%"
  end

  test "light buttons control", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/light")

    # element(view, html_tag, [text_filter])

    # testing the button directly using a button text.
    assert view |> element("button", "Up") |> render_click() =~ "20%"
    assert view |> element("button", "Down") |> render_click() =~ "10%"
    assert view |> element("button", "On") |> render_click() =~ "100%"
    assert view |> element("button", "Off") |> render_click() =~ "0%"

    # Avoiding false positive:
    # the last case there is an ambiguity with 0% and xx0%, so to avoid that
    # the previous test: 100% was overwritten with 0% we check that:
    refute render(view) =~ "100%"
  end

  test "min brightness is 0%", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/light")

    assert view |> element("button", "Off") |> render_click() =~ "0%"
    refute render(view) =~ "100%"
    # try to push further 100% should remain in the max value
    assert view |> element("button", "Down") |> render_click() =~ "0%"
  end

  test "max brightness", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/light")

    assert view |> element("button", "On") |> render_click() =~ "100%"
    # try to push further 100% should remain in the max value
    assert view |> element("button", "Up") |> render_click() =~ "100%"
  end
end
