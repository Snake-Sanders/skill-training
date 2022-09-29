defmodule GithubClient.Test do
  use ExUnit.Case, async: false
  alias FakeServer.GithubRepo
  alias FakeServer.GithubError
  alias FakeServer.GithubClient
  # import GithubRepo
  # import GithubErro

  @success_repo_params %{name: "success-repo"}
  @failure_repo_params %{name: "failed-repo"}

  test "create_repo when success" do
    response = GithubClient.create_repo(@success_repo_params)
    assert %GithubRepo{name: "success-repo", id: 1} == response
  end

  test "create_repo when failure" do
    response = GithubClient.create_repo(@failure_repo_params)
    assert %GithubError{error_message: "error message"} == response
  end
end
