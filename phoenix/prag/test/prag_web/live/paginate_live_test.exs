defmodule PragWeb.PaginateLiveTest do
  use PragWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  defp create_donations(name) do
    {:ok, donation} =
      %{
        item: name,
        # the following are irrelevant attributes:
        days_until_expires: 4,
        emoji: "🐟",
        quantity: 1
      }
      |> Prag.Donations.create_donation()

    donation
  end

  test "footer buttons navigate the pages", %{conn: conn} do
    _donations = Enum.map(1..40, fn id -> create_donations("fish-#{id}") end)

    {:ok, view, _html} = live(conn, "/paginate")

    assert has_element?(view, "#donations")

    refute has_element?(view, "#pag-buttons", "Previous")
    assert has_element?(view, "#pag-buttons", "1")
    assert has_element?(view, "#pag-buttons", "2")
    assert has_element?(view, "#pag-buttons", "3")
    assert has_element?(view, "#pag-buttons", "Next")

    view
    |> element("#pag-buttons a", "Next")
    |> render_click()

    assert_patch(view, "/paginate?page=2&per_page=5")
    assert has_element?(view, "#pag-buttons", "Previous")

    view
    |> element("#pag-buttons a", "Previous")
    |> render_click()

    assert_patch(view, "/paginate?page=1&per_page=5")

    view
    |> element("#pag-buttons a", "3")
    |> render_click()

    assert_patch(view, "/paginate?page=3&per_page=5")

    assert has_element?(view, "#pag-buttons a", "1")
    assert has_element?(view, "#pag-buttons a", "2")
    assert has_element?(view, "#pag-buttons a", "4")
    assert has_element?(view, "#pag-buttons a", "5")
  end

  test "navigate using the pages and per-page in the url", %{conn: conn} do
    donations = Enum.map(1..5, fn id -> create_donations("fish-#{id}") end)

    # inspect DB:
    # Enum.map(donations, &(IO.puts("donation id: #{&1.id}, name: #{&1.item}")))
    don_1 = List.first(donations)
    {don_2, _rest} = List.pop_at(donations, 1)
    {don_3, _rest} = List.pop_at(donations, 2)
    {don_4, _rest} = List.pop_at(donations, 3)

    # strategy: show one item per page

    # checks the first page
    {:ok, view, _html} = live(conn, "/paginate?page=1&per_page=1")
    assert has_element?(view, "#donations")
    assert has_element?(view, "#donation-#{don_1.id}")
    refute has_element?(view, "#donation-#{don_2.id}")

    # checks the second page
    {:ok, view, _html} = live(conn, "/paginate?page=2&per_page=1")
    refute has_element?(view, "#donation-#{don_1.id}")
    assert has_element?(view, "#donation-#{don_2.id}")

    # checks the second page with 2 elements
    {:ok, view, _html} = live(conn, "/paginate?page=2&per_page=2")
    refute has_element?(view, "#donation-#{don_1.id}")
    refute has_element?(view, "#donation-#{don_2.id}")
    assert has_element?(view, "#donation-#{don_3.id}")
    assert has_element?(view, "#donation-#{don_4.id}")
  end

  test "patches the URL as expected when the user changes the per-page form", %{conn: conn} do
    donations = Enum.map(1..5, fn id -> create_donations("fish-#{id}") end)

    {:ok, view, _html} = live(conn, "/paginate")

    view
    |> form("#select-per-page", %{"per-page": 5})
    |> render_change()

    assert_patch(view, "/paginate?page=1&per_page=5")
  end
end
