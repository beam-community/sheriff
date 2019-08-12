![](logo.png)

[![Build Status](https://travis-ci.org/beam-community/sheriff.svg?branch=master)](https://travis-ci.org/beam-community/sheriff)

Sheriff is a simple minimal-dependency way to manage policy based authorization for Plug based applications, including [Phoenix](https://github.com/phoenixframework/phoenix).

If you're looking for authentication check out [Guardian](https://github.com/ueberauth/guardian) or [Ueberauth](https://github.com/ueberauth/ueberauth) for third-party oauth.

## Installation

The latest on [hex.pm](https://hex.pm/packages/sheriff):
```elixir
def deps do
  [{:sheriff, "~> 1.0"}]
end
```

If you prefer living on the edge use `master`:

```elixir
def deps do
  [{:sheriff, github: "doomspork/sheriff"}]
end
```

## Current User

By default Sheriff will look for the current user in the `:current_user` key within `Plug.Conn.private`.
Since this may not be compatible with all applications, we've provided a way to reconfigure the key:

```elixir
config :sheriff,
  resource_key: :your_desired_resource_key
```

## Resource Loading

Resource loaders are responsible for retrieving the requested resources.  A global loader can be specified in your application configuration or individual loaders can be supplied on a per plug basis.

Sheriff ships with a convenient `Sheriff.ResourceLoader` behaviour:

```elixir
defmodule Example.UserLoader do
  @behaviour Sheriff.ResourceLoader

  def fetch_resource(:show, %{"id" => id}), do: Repo.get(User, id)
  def fetch_resource(:index, _params), do: Repo.all(User)
end
```

## Laws

In Sheriff authorization is handled with laws; which are modules that implement the `Sheriff.Law` behaviour:

```elixir
defmodule Example.UserLaw do
  @behaviour Sheriff.Law

  alias Example.User

  # Admins can see all the things!
  def legal?(%User{role: "admin"}, _request, _resource), do: true

  # Users can access themselves
  def legal?(%User{id: id}, _request, %User{id: id}), do: true

  # Team admin can view team members
  def legal?(%User{role: "team_admin", team_id: id}, :show, resources) do
    Enum.all?(resources, &(&1.team_id == team_id))
  end

  # No match, no access
  def legal?(_, _, _), do: false
end
```

## Plugs

There are two plugs that serve as the workhorses of Sheriff, these need to occur __after__ `Plug.Parser`:

+ `Sheriff.LoadResource` - Uses the configured `ResourceLoader` to fetch the target resource
+ `Sheriff.LawEnforcer`  - Apply a given `Law` against the current user, target resource, and request.

When defining our authorization pipeline we could use something like this:

```elixir
plug Sheriff.LoadResource, loader: Example.UserLoader
plug Sheriff.LawEnforcer, law: Example.UserLaw
```

_Note:_ The `Sheriff.LoadResource` and the `Sheriff.ResourceLoader` behaviour are for simple use-cases.
For more involved resource fetching you may find it's necessary to implement your own plug, make sure the loaded resources are assigned to the connection under the  `:sheriff_resource` key.

## Error Handling

Sheriff has just three error scenarios we need to address:

+ The requested resource is missing
+ The current user is not authenticated
+ The current user is not authorized to perform the requested action

To handle these cases we'll want to provide an error handler for Sheriff.  Our handler can be a module that
implements `resource_missing/1`, `unauthenticated/1`, and `unauthorized/1`; the `Sheriff.Handler` behaviour is optional.

Sheriff makes no assumptions so we need to tell it which module to use as a handler:

```elixir
config :sheriff,
  handler: Example.ErrorHandler
```

That's it!
