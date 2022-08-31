defmodule PragWeb.VolunteersLiveTest do
  use PragWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  defp create_volunteer() do
    {:ok, volunteer} =
      Prag.Volunteers.create_volunteer(%{
        name: "New Volunteer",
        phone: "303-555-1212"
      })

    volunteer
  end

  test "adds valid volunteer to list", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/volunteers")

    valid_attrs = %{name: "New Volunteer", phone: "303-555-1212"}

    view
    |> form("#create-volunteer", %{volunteer: valid_attrs})
    |> render_submit()

    assert has_element?(view, "#volunteers", valid_attrs.name)
  end

  test "displays live validation", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/volunteers")

    invalid_attrs = %{name: "New Volunteer", phone: ""}

    # the validation happens when the form changes, not in submit
    view
    |> form("#create-volunteer", %{volunteer: invalid_attrs})
    |> render_change()

    # the message should be displayed in the form
    assert has_element?(view, "#create-volunteer", "can't be blank")
  end

  test "clicking status button toggles status", %{conn: conn} do
    volunteer = create_volunteer()

    {:ok, view, _html} = live(conn, "/volunteers")

    status_button = "#volunteer-#{volunteer.id} button"

    view
    |> element(status_button, "Check Out")
    |> render_click()

    assert has_element?(view, status_button, "Check In")
  end

  test "receives real-time updates", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/volunteers")

    # to simulate a volunteer is added in another browser we can add it
    # directly in the database via the context function. This function
    # emits a broadcast to all the clients.
    external_volunteer = create_volunteer()
    assert has_element?(view, "#volunteers", external_volunteer.name)
  end
end
