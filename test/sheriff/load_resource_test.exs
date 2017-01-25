defmodule Sheriff.LoadResourceTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Sheriff.TestHelper

  alias Sheriff.{LoadResource, TestErrorHandler, TestLoader}

  test "fetches resource using application configuration" do
    conn =
      :get
      |> conn("/users?id=42")
      |> run_plug(Plug.Parsers, parsers: [:urlencoded])
      |> run_plug(LoadResource, [])

    assert conn.private[:sheriff_resource] == %{id: 42}
  end

  test "fetches resource using phoenix_action" do
    conn =
      :get
      |> conn("/users?id=13")
      |> Plug.Conn.put_private(:phoenix_action, :show)
      |> run_plug(Plug.Parsers, parsers: [:urlencoded])
      |> run_plug(LoadResource, [])

    assert conn.private[:sheriff_resource] == %{id: 13}
  end

  test "fetches resource using plug configuration" do
    conn =
      :get
      |> conn("/users?id=1")
      |> run_plug(Plug.Parsers, parsers: [:urlencoded])
      |> run_plug(LoadResource, loader: TestLoader)

    assert conn.private[:sheriff_resource] == %{id: 1}
  end

  test "fetches missing resource" do
    conn =
      :get
      |> conn("/users?id=99")
      |> run_plug(Plug.Parsers, parsers: [:urlencoded])
      |> run_plug(LoadResource, loader: TestLoader, handler: TestErrorHandler)

    assert conn.private[:sheriff_resource] == nil
    assert conn.status == 404
  end
end
