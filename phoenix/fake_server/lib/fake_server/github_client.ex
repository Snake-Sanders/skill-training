defmodule FakeServer.GithubClient do
  # https://hexdocs.pm/elixir/Application.html#get_env/3
  @base_url Application.get_env(:fake_server, :api_base_url)

  alias FakeServer.GithubRepo
  alias FakeServer.GithubError


  def create_repo(params) do
    url = @base_url <> "/repos"

    IO.puts("+++")
    #IO.puts("base url #{inspect(@base_url  <> "/repos")}")

    IO.puts("params: #{inspect(params)}")
    IO.puts("header: #{inspect(headers())}")
    body = Poison.encode!(params)

    resp = HTTPoison.post(url, body, headers())
    |> IO.inspect(label: "--- http response")
    |> handle_response()

    resp
  end

  defp handle_response(resp) do
    case resp do
      {:ok, %{body: body, status_code: 200}} ->
        %GithubRepo{id: body.id, name: body.name}

      {:ok, %{body: _body, status_code: 422}} ->
        %GithubError{error_message: "failed"}

      resp ->
        IO.puts("bard httpoison response: #{inspect(resp)}")
    end
  end

  defp headers do
    [{"content-type", "application/json"}]
  end
end
