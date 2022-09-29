defmodule FakeServer.GithubRepo do
  defstruct [:name, :id]
end

defmodule FakeServer.GithubError do
  defstruct [:error_message]
end
