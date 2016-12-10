defmodule Sheriff.Plug do
  @moduledoc """
  Not an actual Plug but a collection of Plug related
  helper functions.
  """

  import Plug.Conn, only: [halt: 1]

  @handler Application.get_env(:sheriff, :handler)

  @doc """
  Retrieve the current Actor resource.
  """
  def current_actor(conn), do: conn.private[:sheriff_actor]

  @doc """
  Retrieve the current resource for the request.
  """
  def current_resource(conn), do: conn.private[:sheriff_resource]

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

  def from_opts(opts, key), do: Keyword.get(opts, key) || Application.get_env(:sheriff, key)
end
