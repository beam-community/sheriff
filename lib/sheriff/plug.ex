defmodule Sheriff.Plug do
  @moduledoc """
  Not an actual Plug but a collection of Plug related
  helper functions.
  """

  import Plug.Conn, only: [halt: 1, put_private: 3]

  @doc """
  Retrieve the current Actor resource.
  """

  @spec current_actor(Plug.Conn.t()) :: any
  def current_actor(conn), do: conn.private[actor_key()]

  @doc """
  Retrieve the current resource for the request.
  """

  @spec current_resource(Plug.Conn.t()) :: any
  def current_resource(conn), do: conn.private[resource_key()]

  @spec conn_action(Plug.Conn.t()) :: atom | {atom, binary}
  def conn_action(conn), do: conn.private[:phoenix_action] || conn_tuple(conn)

  @spec from_opts(keyword, atom, any) :: any
  def from_opts(opts, key, default \\ nil)

  def from_opts(opts, key, default) when opts in [nil, []],
    do: Application.get_env(:sheriff, key, default)

  def from_opts(opts, key, default), do: Keyword.get(opts, key) || from_opts(nil, key, default)

  @spec handle_error(atom, Plug.Conn.t(), keyword) :: Plug.Conn.t()
  def handle_error(error, conn, opts) do
    opts
    |> from_opts(:handler)
    |> apply(error, [conn])
    |> halt
  end

  def set_current_actor(conn, actor), do: put_private(conn, actor_key(), actor)

  def set_current_resource(conn, resource), do: put_private(conn, resource_key(), resource)

  defp actor_key, do: Application.get_env(:sheriff, :actor_key, :sheriff_actor)

  defp conn_tuple(conn) do
    method =
      conn.method
      |> String.downcase()
      |> String.to_atom()

    {method, conn.request_path}
  end

  defp resource_key, do: Application.get_env(:sheriff, :resource_key, :sheriff_resource)
end
