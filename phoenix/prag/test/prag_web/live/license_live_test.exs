defmodule PragWeb.LicenseLiveTest do
  use PragWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "updating number of seats changes seats and amount (I)", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/license")

    rendered = render(view)
    assert rendered =~ "3"
    assert rendered =~ "$60.00"

    # view
    # |> element("form")
    # |> render_change(%{seats: 4})

    render =
      view
      |> form("#update-seats", %{seats: 4})
      |> render_change()

    assert render =~ "4"
    assert render =~ "$80.00"
  end

  test "updating number of seats changes seats and amount (II)", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/license")

    # checks if the initial status of the form is correct.
    assert has_element?(view, "#seats", "3")
    assert has_element?(view, "#amount", "$60.00")

    # then, changes the range bar from 3 to 4 seats:
    view
    |> form("#update-seats", %{seats: 4})
    |> render_change()

    assert has_element?(view, "#seats", "4")
    assert has_element?(view, "#amount", "$80.00")

    view
    |> form("#update-seats", %{seats: 10})
    |> render_change()

    assert has_element?(view, "#amount", "$175.00")

  end
end
