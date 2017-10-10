defmodule Sheriff.LawEnforcer do
  @moduledoc """
  Enforces authorization laws for actors and resources
  """

  import Sheriff.Plug

  @doc false
  def init(opts), do: opts

  @doc """
  Apply a law against the current actor and requested resource.
  """
  def call(conn, opts) do
    action = conn_action(conn)
    actor = current_actor(conn)
    law = Keyword.fetch!(opts, :law)
    resource = current_resource(conn)

    if legal?(law, action, actor, resource) do
      conn
    else
      handle_error(:unauthorized, conn, opts)
    end
  end

  defp legal?(law, action, actor, resource), do: apply(law, :legal?, [actor, action, resource])
end
