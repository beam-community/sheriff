defmodule Sheriff.LawEnforcer do
  @moduledoc """
  Enforces authorization laws for actors and resources
  """

  import Sheriff.Plug

  alias Sheriff.Plug

  @doc false
  def init(opts), do: opts

  @doc """
  Apply a law against the current actor and requested resource.
  """
  def call(conn, opts) do
    law = Keyword.fetch!(opts, :law)

    conn
    |> fetch_actor(opts)
    |> fetch_resource
    |> legal?(law)
  end

  defp fetch_actor(conn, opts) do
    resource_key = Plug.from_opts(opts, :resource_key, :current_user)
    {conn.private[resource_key], conn, opts}
  end

  defp fetch_resource({actor, conn, opts}) do
    resource = Plug.current_resource(conn)
    {actor, resource, conn, opts}
  end

  defp legal?({actor, resource, conn, opts}, law) do
    permitted = apply(law, :legal?, [actor, conn_action(conn), resource])
    if permitted, do: conn, else: handle_error(:unauthorized, conn, opts)
  end
  defp legal?(conn, _), do: conn
end
