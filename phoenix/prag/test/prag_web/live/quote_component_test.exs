defmodule PragWeb.QuoteComponentTest do
  use PragWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias PragWeb.QuoteComponent

  test "renders quote with 24-hour expiry by default" do
    assigns = [
      material: "sand",
      weight: 2.0,
      price: 4.0,
      charge: 5
    ]

    html = render_component(&QuoteComponent.quote/1, assigns)

    assert html =~"2.0 pounds of sand"
    assert html =~"expires in 24 hours"
  end
end
