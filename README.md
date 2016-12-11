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

## Current User

Sheriff relies on the the `:current_user` key being set in the `Plug.Conn.private` map.

## Resource Loading

Resource loaders are responsible for retrieving the targetted resource provided for a specific request.  A global loader can be can be specified in your application configuration or individual loaders can be supplied on a per plug basis.

Sheriff ships with a convenient `Sheriff.ResourceLoader` behaviour:

```elixir
defmodule Example.UserLoader do
  @behaviour Sheriff.ResourceLoader

  def fetch_resource(:show, %{"id" => id}), do: Repo.get(User, id)
  def fetch_resource(:index, _params), do: Repo.all(User)
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
  def permitted?(%User{role: "team_admin", team_id: id}, :show, resources) do
    Enum.all?(resources, &(&1.team_id == team_id)
  end

  # Not match, no access
  def permitted?(_, _, _), do: false
end
```

## Plugs

There are two plugs that Sheriff relies upon of which should occur _after_ `Plug.Parser`:

+ `Sheriff.Plug.LoadResource` - Uses the configured `ResourceLoader` to fetch the target resource
+ `Sheriff.Plug.EnforcePolicy` - Apply a given `Policy` against the current user, target resource, and request.

When setting up our pipeline, we can use something like this:

```elixir
plug Sheriff.Plug.LoadResource, resource_loader: Example.UserLoader
plug Sheriff.Plug.EnforcePolicy, policy: Example.UserPolicy
```

## Error Handling

Within Sheriff there are three error scenerios we want to address:

+ The request resource is missing
+ The current user is not authenticated
+ The current user is not authorized to perform the requested action

We'll want to provide a handler to Sheriff.  A handler is any module that
implements `resource_missing/1`, `unauthenticated/1`, and `unauthorized/1`;
you may can use the `Sheriff.Handler` behaviour if you'd like.

That's it!
