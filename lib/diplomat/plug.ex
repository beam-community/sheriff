defmodule Diplomat.Plug do
  @moduledoc """
  Not an actual PLug but a collection of Plug related
  helper functions.
  """

  import Plug.Conn, only: [halt: 1]

  @handler Application.get_env(:diplomat, :handler)

  @doc """
  Retrieve the current Actor resource.
  """
  def current_actor(conn), do: conn.private[:diplomat_actor]

  @doc """
  Retrieve the current resource for the request.
  """
  def current_resource(conn), do: conn.private[:diplomat_resource]

  def conn_tuple(conn) do
    method =
      conn.method
      |> String.downcase
      |> String.to_atom

    {method, conn.request_path}
  end

  def handle_error(error, conn, opts) do
    opts
    |> from_opts(:handler)
    |> apply(error, [conn])
    |> halt
  end

  def from_opts(opts, key), do: Keyword.get(opts, key) || Application.get_env(:diplomat, key)
end
