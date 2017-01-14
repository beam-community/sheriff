# Sheriff

A simple minimal-dependency way to manage policy based authorization.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `sheriff` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:sheriff, "~> 0.2"}]
    end
    ```

  2. Ensure `sheriff` is started before your application:

    ```elixir
    def application do
      [applications: [:sheriff]]
    end
    ```

## Current User

Sheriff defaults to looking in `Plug.Conn.private` for `:current_user`, but this may not be compatible with all appliaction so we can configure the key:

```elixir
config Sheriff,
  resource_key: :your_desired_resource_key
```

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

In Sheriff authorization is handled with policies which are modules that implement the `Sheriff.Policy` behaviour:

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

There are two plugs that serve as the workhorses of Sheriff, these need to occur __after__ `Plug.Parser`:

+ `Sheriff.Plug.LoadResource` - Uses the configured `ResourceLoader` to fetch the target resource
+ `Sheriff.Plug.EnforcePolicy` - Apply a given `Policy` against the current user, target resource, and request.

When defining our authorization pipeline we could use something like this:

```elixir
plug Sheriff.Plug.LoadResource, loader: Example.UserLoader
plug Sheriff.Plug.EnforcePolicy, policy: Example.UserPolicy
```

## Error Handling

Sheriff has just three error scenerios we need to address:

+ The requested resource is missing
+ The current user is not authenticated
+ The current user is not authorized to perform the requested action

To handle these cases we'll want to provide an error handler for Sheriff.  Our handler can be and module that
implements `resource_missing/1`, `unauthenticated/1`, and `unauthorized/1`; the `Sheriff.Handler` behaviour is optional.

Sheriff makes no assumptions so we need to tell it which module to use as a handler:

```elixir
config Sheriff,
  handler: YourApp.ErrorHandler
```

That's it!
