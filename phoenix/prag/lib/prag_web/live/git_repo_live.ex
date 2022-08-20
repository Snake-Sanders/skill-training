defmodule PragWeb.GitRepoLive do
  use PragWeb, :live_view

  alias Prag.GitRepos

  def mount(_params, _session, socket) do
    socket = assign_defaults(socket)
    # {:ok, socket, temporary_assigns: [repos: []]}
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Trending Git Repos</h1>
    <div id="repos">
      <form phx-change="filter">
        <div class="filters">
          <select name="fil-language">
            <%= my_opt_for_select(language_options(), @g_language) %>
          </select>

          <select name="fil-license">
            <%= my_opt_for_select(license_options(), @g_license) %>
          </select>

          <a href="#" phx-click="clear">Clear All</a>
        </div>
      </form>

      <div class="repos">
        <ul>
          <%= for repo <- @repos do %>
            <li>
              <div class="first-line">
                <div class="group">
                  <img src="images/terminal.svg">
                  <a href="{repo.owner_url}">
                    <%= repo.owner_login %>
                  </a>
                  /
                  <a href="{repo.url}">
                    <%= repo.name %>
                  </a>
                </div>
                <button>
                  <img src="images/star.svg">
                  Star
                </button>
              </div>
              <div class="second-line">
                <div class="group">
                  <span class={"language #{repo.language}"}>
                    <%= repo.language %>
                  </span>
                  <span class="license">
                    <%= repo.license %>
                  </span>
                  <%= if repo.fork do %>
                    <img src="images/fork.svg">
                  <% end %>
                </div>
                <div class="stars">
                  <%= repo.stars %> stars
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  defp my_opt_for_select(option_list, selected_option) do
    assigns = Enum.into([selected_option: selected_option], %{})

    ~H"""
    <%= for {name, value} <- option_list do %>
      <option value={value} selected={value == @selected_option}><%= name %></option>
    <% end %>
    """
  end

  defp language_options() do
    [
      "All Languages": "",
      "Elixir": "elixir",
      Ruby: "ruby",
      JavaScript: "js"
    ]
  end

  defp license_options() do
    [
      "All Licenses": "",
      MIT: "mit",
      Apache: "apache",
      BSDL: "bsdl"
    ]
  end

  # it is convinient to call g_language -> language, to it can also be use for both DB query and
  # updating the assigns. However they were prefixed with 'g_' to distiguis where each variable comes
  # from, 'g' stands for global.
  def handle_event("filter", %{"fil-language" => language, "fil-license" => license}, socket) do
    params = [language: language, license: license]

    repos = GitRepos.list_git_repos(params)

    socket = assign(socket, repos: repos, g_language: language, g_license: license)

    {:noreply, socket}
  end

  def handle_event("clear", _session, socket) do
    socket = assign_defaults(socket)
    {:noreply, socket}
  end

  defp assign_defaults(socket) do
    assign(socket,
      repos: GitRepos.list_git_repos(),
      g_language: "",
      g_license: ""
    )
  end
end
