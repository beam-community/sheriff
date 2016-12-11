defmodule Sheriff.Plug.EnforcePolicy do
  @moduledoc """
  Test the policy against the current route, actor, and resource.
  """

  import Sheriff.Plug
  alias Sheriff.Plug

  @not_permitted "you are not permitted to perform the requested action"

  @doc false
  def init(opts), do: opts

  @doc """
  Verify against the policy that the actor is permitted to interact
  with the given resource.
  """
  def call(conn, opts) do
    policy = Keyword.fetch!(opts, :policy)

    conn
    |> fetch_actor
    |> fetch_resource(opts)
    |> permitted?(policy)
  end

  defp fetch_actor(conn) do
    {conn.private[:current_user], conn}
  end

  defp fetch_resource({nil, conn}, opts), do: handle_error(:unauthenticated, conn, opts)
  defp fetch_resource({actor, conn}, opts) do
    resource = Plug.current_resource(conn)
    {actor, resource, conn, opts}
  end

  defp permitted?({actor, resource, conn, opts}, policy) do
    permitted = apply(policy, :permitted?, [actor, conn_action(conn), resource])
    if permitted, do: conn, else: handle_error(:unauthorized, conn, opts)
  end
  defp permitted?(conn, _), do: conn
end
