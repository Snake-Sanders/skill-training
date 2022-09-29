defmodule PentoWeb.WrongLive do
  use Phoenix.LiveView, Layout: {PentoWeb.LayoutView, "live.html"}

  # used by the reder in .link
  # import Phoenix.Component

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, score: 0, has_won: false, secret: Enum.random(1..10), message: "Make a guess:")}
  end

  def render(assigns) do
    ~H"""
      <h1>Your score: <%= @score %></h1>
      <h2>
        <%= @message %>
      </h2>
      <h2>
        <%= for n <- 1..10 do %>
          <a href="#" phx-click="guess" phx-value-number= {n} ><%= n %></a>
        <% end %>

        <%= if @has_won do %>
        <!-- TODO: <.link patch={Routes.live_path(@socket, PentoWeb.WrongLive)}>Resetart Game</.link> -->
        <% end %>
    </h2>
    """
  end

  def handle_event("guess", %{"number" => guess} = _data, socket) do
    secret = socket.assigns.secret
    number = guess |> String.to_integer()

    socket =
      case secret do
        ^number ->
          assign(socket,
            message: "Your guess: #{guess}. Great!",
            score: socket.assigns.score + 1
          )

        _ ->
          assign(socket,
            message: "Your guess: #{guess}. Wrong. Guess again. try #{secret}",
            score: socket.assigns.score - 1
          )
      end

    {:noreply, socket}
  end
end
