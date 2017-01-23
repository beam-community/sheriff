ExUnit.start()

defmodule Sheriff.TestHelper do
  def run_plug(conn, plug_module, opts) do
    opts = apply(plug_module, :init, [opts])
    apply(plug_module, :call, [conn, opts])
  end
end

defmodule Sheriff.TestErrorHandler do
  @behaviour Sheriff.Handler

  import Plug.Conn

  def resource_missing(conn), do: send_resp(conn, 404, "not found")
  def unauthenticated(conn), do: send_resp(conn, 401, "unauthorized")
  def unauthorized(conn), do: send_resp(conn, 403, "unauthorized")
end

defmodule Sheriff.TestLaw do
  @behaviour Sheriff.Law

  def permitted?(%{id: _}, :index, _), do: true

  def permitted?(%{id: id}, {:get, "/users"}, %{id: id}), do: true
  def permitted?(%{role: "admin"}, _, _), do: true
  def permitted?(_, _, _), do: false
end

defmodule Sheriff.TestLoader do
  @behaviour Sheriff.ResourceLoader

  def fetch_resource(:show, %{"id" => "13"}), do: {:ok, %{id: 13}}
  def fetch_resource(:index, _), do: {:ok, [%{id: 1}, %{id: 2}]}

  def fetch_resource({:get, "/users"}, %{"id" => "42"}), do: {:ok, %{id: 42}}
  def fetch_resource({:get, _}, %{"id" => "1"}), do: {:ok, %{id: 1}}
  def fetch_resource(_, _), do: {:error, "resource not found"}
end
