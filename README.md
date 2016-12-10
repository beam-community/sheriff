# Sheriff

Build simple and robust authorization systems with Elixir and Plug.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `sheriff` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:sheriff, "~> 0.1.0"}]
    end
    ```

  2. Ensure `sheriff` is started before your application:

    ```elixir
    def application do
      [applications: [:sheriff]]
    end
    ```

## Plugs

There are two main plugs for Sheriff both of which should occur _after_ `Plug.Parser`:

+ `Sheriff.Plug.LoadResource` - Use the configured `ResourceLoader` to retrieve the target resource
+ `Sheriff.Plug.EnsurePermitted` - Apply the specified `Policy` using the current user, target resource, and request.

## Current User

Sheriff relies on the the `:current_user` key being set in the `Plug.Conn.private` map.

## Resource Loading

Resource loaders are responsible for retrieving the targetted resource provided with the curernt request and parameters.  Resource loaders can be specified in your application configuration or on a per plug basis.

Sheriff ships with a convenient `Sheriff.ResourceLoader` behaviour:

```elixir
defmodule Example.UserLoader do
  @behaviour Sheriff.ResourceLoader

  def fetch_resource({:get, "/users"}, %{"id" => id}), do: Repo.get(User, id)
  def fetch_resource({:get, "/users"}, _params), do: Repo.all(User)
end

```

## Policies

Policies are modules that implement the `Sheriff.Policy` behaviour:

```elixir
defmodule Example.UserPolicy do
  @behaviour Sheriff.Policy

  alias Example.User

  # Admins can see all the things!
  def permitted?(%User{role: "admin"}, _request, _resource), do: true

  # Users can access themselves
  def permitted?(%User{id: id}, _request, %User{id: id}), do: true

  # Team admin can view team members
  def permitted?(%User{role: "team_admin", team_id: id}, {:get, "/users"}, resources) do
    Enum.all?(resources, &(&1.team_id == team_id)
  end

  # Not match, no access
  def permitted?(_, _, _), do: false
end
```

To use our policy, we need our `Sheriff.Plug.EnsurePermitted` plug:

```elixir
plug Sheriff.Plug.EnsurePermitted, policy: Example.UserPolicy
```

That's it!
