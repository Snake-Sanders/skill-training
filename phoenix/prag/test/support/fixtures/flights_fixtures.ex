defmodule Prag.FlightsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Prag.Flights` context.
  """

  @doc """
  Generate a flight.
  """
  def flight_fixture(attrs \\ %{}) do
    {:ok, flight} =
      attrs
      |> Enum.into(%{
        arrival_time: ~N[2022-08-18 13:08:00],
        departure_time: ~N[2022-08-18 13:08:00],
        destination: "some destination",
        number: "some number",
        origin: "some origin"
      })
      |> Prag.Flights.create_flight()

    flight
  end
end
