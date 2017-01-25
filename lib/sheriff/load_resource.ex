defmodule Sheriff.LoadResource do
  @moduledoc """
  Load the requested resource and store it on the connection.
  """

  import Sheriff.Plug
  import Plug.Conn, only: [put_private: 3]

  @doc false
  def init(opts), do: opts

  @doc """
  Loads a resource for the requested path.  In the event of an error `resource_missing/1`
  will be invoked on the configured error handler.
  """
  @spec call(Plug.Conn.t, keyword) :: Plug.Conn.t
  def call(conn, opts) do
    opts
    |> resource_loader
    |> fetch_resource(conn)
  end

  defp resource_loader(opts) do
    {from_opts(opts, :loader), opts}
  end

  defp fetch_resource({loader, opts}, conn) do
    case apply(loader, :fetch_resource, [conn_action(conn), conn.params]) do
      {:ok, resource} ->
        put_private(conn, :sheriff_resource, resource)
      {:error, _reason} ->
        handle_error(:resource_missing, conn, opts)
    end
  end
end
