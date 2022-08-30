defmodule PragWeb.AutocompleteLiveTest do
  use PragWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  def create_store(attrs) do
    {:ok, store} =
      attrs
      # these fields are irrelevant for tests:
      |> Enum.into(%{
        street: "street",
        phone_number: "phone",
        # city: "city",
        open: true,
        hours: "hours"
      })
      |> Prag.Stores.create_store()

    store
  end

  test "typing in city field suggests a city", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/autocomplete")

    # add
    assert has_element?(view, "#city-search")

    view
    |> form("#city-search", %{city: "D"})
    |> render_change()

    refute has_element?(view, "#matches option", "Fenver")
    assert has_element?(view, "#matches option", "Denver")
  end

  test "search by city shows matching stores", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/autocomplete")

    # add stores to the test database
    _store_1 = create_store(%{name: "store 1", zip: "80204", city: "Denver, CO"})
    _store_2 = create_store(%{name: "store 2", zip: "80204", city: "Denver, CO"})
    _store_3 = create_store(%{name: "store 3", zip: "80204", city: "Denver, CO"})
    _store_4 = create_store(%{name: "store 4", zip: "80204", city: "Denver, CO"})

    # Prag.Stores.list_stores()
    # |> Enum.each(&IO.puts("[#{&1.id}] name: #{&1.name}, zip: #{&1.zip}"))

    assert has_element?(view, "#city-search")

    view
    |> form("#city-search", %{city: "Denver, CO"})
    |> render_submit()

    # open_browser(view)

    assert has_element?(view, "li")
    assert has_element?(view, "li", "store 1")
    assert has_element?(view, "li", "store 2")
    assert has_element?(view, "li", "store 3")
    assert has_element?(view, "li", "store 4")
  end

  test "search by city with no results shows error", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/autocomplete")

    view
    |> form("#city-search", %{city: "Oslo"})
    |> render_submit()

    assert view |> has_element?("[role=alert]", "No stores matching")
  end
end
