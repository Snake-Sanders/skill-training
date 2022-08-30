defmodule PragWeb.FilterLiveTest do
  use PragWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "filter boats by type and price", %{conn: conn} do
    # fill the test DB before connecting
    boat_1 = insert_boat(model: "A", price: "$", type: "fishing")
    boat_2 = insert_boat(model: "B", price: "$$", type: "fishing")
    boat_3 = insert_boat(model: "C", price: "$$", type: "sporting")

    # manual check if they are in the DB
    # Prag.Boats.list_boats()
    # |> Enum.map(fn b -> "[#{b.id}] type: #{b.type}, prices: #{inspect(b.price)}" end)
    # |> Enum.each(&IO.inspect/1)

    {:ok, view, _html} = live(conn, "/filter")

    # check if the filter form exist
    assert has_element?(view, "#change-filter")

    # For debugging you can open the browser automatically:
    # open_browser(view)

    assert has_element?(view, "#boat-#{boat_1.id}")
    assert has_element?(view, boat_card(boat_1))
    assert has_element?(view, boat_card(boat_2)), "can't find #{boat_card(boat_2)}"
    assert has_element?(view, boat_card(boat_3)), "can't find #{boat_card(boat_3)}"

    view
    |> form("#change-filter", %{type: "fishing", prices: ["$"]})
    |> render_change()

    assert has_element?(view, boat_card(boat_1))
    refute has_element?(view, boat_card(boat_2))
    refute has_element?(view, boat_card(boat_3))
  end

  def boat_card(boat), do: "#boat-#{boat.id}"

  defp insert_boat(attrs) do
    {:ok, boat} =
      attrs
      # image is quired attribute, so we add just a file name.
      |> Enum.into(%{image: "image.jpg"})
      |> Prag.Boats.create_boat()

    boat
  end
end
