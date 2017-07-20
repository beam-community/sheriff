defmodule Sheriff.LawEnforcerTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Sheriff.{Plug, TestHelper}

  alias Sheriff.{LawEnforcer, LoadResource, TestErrorHandler, TestLoader, TestLaw}

  setup do
    conn =
      :get
      |> conn("/users?id=1")
      |> run_plug(Plug.Parsers, parsers: [:urlencoded])
      |> run_plug(LoadResource, loader: TestLoader)

    {:ok, conn: conn}
  end

  test "permits requests when actor and resource id match", %{conn: conn} do
    conn =
      conn
      |> Plug.Conn.put_private(:sheriff_actor, %{id: 1})
      |> run_plug(LawEnforcer, law: TestLaw)

    assert current_resource(conn) == %{id: 1}
  end

  test "permits requests for admins", %{conn: conn} do
    conn =
      conn
      |> Plug.Conn.put_private(:sheriff_actor, %{id: 2, role: "admin"})
      |> run_plug(LawEnforcer, law: TestLaw)

    assert current_resource(conn) == %{id: 1}
  end

  test "returns 403 for unauthorized users", %{conn: conn} do
    conn =
      conn
      |> Plug.Conn.put_private(:sheriff_actor, %{id: 9})
      |> run_plug(LawEnforcer, law: TestLaw, handler: TestErrorHandler)

    assert conn.state == :sent
    assert conn.status == 403
  end

  test "supports laws using phoenix_action" do
    Application.put_env(Sheriff, :loader, TestLoader)

    conn =
      :get
      |> conn("/users")
      |> Plug.Conn.put_private(:phoenix_action, :index)
      |> Plug.Conn.put_private(:sheriff_actor, %{id: 9})
      |> run_plug(LoadResource, loader: TestLoader)
      |> run_plug(LawEnforcer, law: TestLaw)

    assert current_resource(conn) == [%{id: 1}, %{id: 2}]
  end
end
