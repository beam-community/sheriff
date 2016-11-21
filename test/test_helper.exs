ExUnit.start()

defmodule Diplomat.TestHelper do
  def run_plug(conn, plug_module, opts) do
    opts = apply(plug_module, :init, [opts])
    apply(plug_module, :call, [conn, opts])
  end
end

defmodule Diplomat.TestErrorHandler do
  @behaviour Diplomat.Handler

  import Plug.Conn

  def resource_missing(conn), do: send_resp(conn, 404, "not found")
  def unauthenticated(conn), do: send_resp(conn, 401, "unauthorized")
  def unauthorized(conn), do: send_resp(conn, 403, "unauthorized")
end

defmodule Diplomat.TestPolicy do
  @behaviour Diplomat.Policy

  def permitted?(%{id: id}, {:get, "/users"}, %{id: id}), do: true
  def permitted?(%{role: "admin"}, _, _), do: true
  def permitted?(_, _, _), do: false
end

defmodule Diplomat.TestLoader do
  @behaviour Diplomat.ResourceLoader

  def fetch_resource({:get, "/users"}, %{"id" => "42"}), do: {:ok, %{id: 42}}
  def fetch_resource(_, %{"id" => "1"}), do: {:ok, %{id: 1}}
  def fetch_resource(_, _), do: {:error, "resource not found"}
end
