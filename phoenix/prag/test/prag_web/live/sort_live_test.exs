defmodule PragWeb.SortLiveTest do
  use PragWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  defp create_donations(attrs) do
    {:ok, donation} =
      attrs
      |> Enum.into(%{
        # the following are irrelevant attributes:
        emoji: "🐟"
      })
      |> Prag.Donations.create_donation()

    donation
  end

  test "checks items are sorted by", %{conn: conn} do
    max_el = 5

    Enum.map(1..max_el, fn id ->
      create_donations(%{
        item: "fish-#{id}",
        days_until_expires: max_el - id,
        quantity: max_el - id
      })
    end)

    # |> Enum.map(&IO.puts("donation id: #{&1.id}, name: #{&1.item}"))

    {:ok, view, _html} = live(conn, "/sort")

    assert has_element?(view, "#donations")

    # desc sort by item:
    element(view, "#sort-by-item a")
    |> render_click()

    assert_patch(view, "/sort?sort_by=item&sort_order=desc&page=1&per_page=5")

    # asc sort by item:
    element(view, "#sort-by-item a")
    |> render_click()

    assert_patch(view, "/sort?sort_by=item&sort_order=asc&page=1&per_page=5")

    # sort by quantity:
    element(view, "#sort-by-quantity a")
    |> render_click()

    assert_patch(view, "/sort?sort_by=quantity&sort_order=desc&page=1&per_page=5")

    # asc sort by expiration:
    element(view, "#sort-by-expiration a")
    |> render_click()

    assert_patch(view, "/sort?sort_by=days_until_expires&sort_order=asc&page=1&per_page=5")
  end

  test "sorts items according to the sort_order and sort_by options in the URL", %{conn: conn} do
    max_el = 5

    donations =
      Enum.map(1..max_el, fn id ->
        create_donations(%{
          item: "fish-#{id}",
          days_until_expires: max_el - id,
          quantity: max_el - id
        })
      end)

    {:ok, view, _html} = live(conn, "/sort?sort_by=quanity&sort_order=asc")

    # the regex attemp here is the following:
    # ~r/fish-1-*fish-2.*fish-3.*fish-4.*fish-5.*/s
    # note the `s` at the end, after the regex body. that is the option to make "."
    # to capture verything even new lines.
    re =
      donations
      |> Enum.take(5)
      # creates: fish-1-*fish-2.*...
      |> Enum.reduce("", fn don, acc -> "#{acc}#{don.item}.*" end)
      # compiles with the option `s`
      |> Regex.compile!("s")

    assert String.match?(render(view), re)
    # assert render(view) =~r/names/
  end
end
