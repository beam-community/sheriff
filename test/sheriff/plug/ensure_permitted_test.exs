defmodule Sheriff.Plug.EnsurePermittedTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Sheriff.TestHelper

  alias Sheriff.{Plug.EnsurePermitted,
                  Plug.LoadResource,
                  TestErrorHandler,
                  TestLoader,
                  TestPolicy}

  setup do
    conn =
      :get
      |> conn("/users?id=1")
      |> run_plug(Plug.Parsers, parsers: [:urlencoded])
      |> run_plug(LoadResource, resource_loader: TestLoader)

    {:ok, conn: conn}
  end

  test "permits requests when actor and resource id match", %{conn: conn} do
    conn =
      conn
      |> Plug.Conn.put_private(:current_user, %{id: 1})
      |> run_plug(EnsurePermitted, policy: TestPolicy)

    assert conn.private[:sheriff_resource] == %{id: 1}
  end

  test "permits requests for admins", %{conn: conn} do
    conn =
      conn
      |> Plug.Conn.put_private(:current_user, %{id: 2, role: "admin"})
      |> run_plug(EnsurePermitted, policy: TestPolicy)

    assert conn.private[:sheriff_resource] == %{id: 1}
  end

  test "returns 401 for unauthenticated users", %{conn: conn} do
    conn =
      conn
      |> Plug.Conn.put_private(:current_user, nil)
      |> run_plug(EnsurePermitted, policy: TestPolicy, handler: TestErrorHandler)

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "returns 403 for unauthorized users", %{conn: conn} do
    conn =
      conn
      |> Plug.Conn.put_private(:current_user, %{id: 9})
      |> run_plug(EnsurePermitted, policy: TestPolicy, handler: TestErrorHandler)

    assert conn.state == :sent
    assert conn.status == 403
  end

  test "supports policies using phoenix_action" do
    Application.put_env(:sheriff, :resource_loader, TestLoader)

    conn =
      :get
      |> conn("/users")
      |> Plug.Conn.put_private(:phoenix_action, :index)
      |> Plug.Conn.put_private(:current_user, %{id: 9})
      |> run_plug(LoadResource, resource_loader: TestLoader)
      |> run_plug(EnsurePermitted, policy: TestPolicy)

    assert conn.private[:sheriff_resource] == [%{id: 1}, %{id: 2}]
  end
end
