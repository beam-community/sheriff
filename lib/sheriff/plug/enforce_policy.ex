defmodule Sheriff.Plug.EnforcePolicy do
  @moduledoc """
  Enforces authorization policies for actors and resources
  """

  import Sheriff.Plug

  alias Sheriff.Plug

  @doc false
  def init(opts), do: opts

  @doc """
  Apply a policy against the current actor and requested resource.
  """
  def call(conn, opts) do
    policy = Keyword.fetch!(opts, :policy)

    conn
    |> fetch_actor(opts)
    |> fetch_resource
    |> permitted?(policy)
  end

  defp fetch_actor(conn, opts) do
    resource_key = Plug.from_opts(opts, :resource_key, :current_user)
    {conn.private[resource_key], conn, opts}
  end

  defp fetch_resource({nil, conn, opts}), do: handle_error(:unauthenticated, conn, opts)
  defp fetch_resource({actor, conn, opts}) do
    resource = Plug.current_resource(conn)
    {actor, resource, conn, opts}
  end

  defp permitted?({actor, resource, conn, opts}, policy) do
    permitted = apply(policy, :permitted?, [actor, conn_action(conn), resource])
    if permitted, do: conn, else: handle_error(:unauthorized, conn, opts)
  end
  defp permitted?(conn, _), do: conn
end
