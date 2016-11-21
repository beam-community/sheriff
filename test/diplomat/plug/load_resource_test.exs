defmodule Diplomat.Plug.LoadResourceTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Diplomat.TestHelper

  alias Diplomat.{Plug.LoadResource, TestErrorHandler, TestLoader}

  test "fetches resource using application configuration" do
    Application.put_env(:diplomat, :resource_loader, TestLoader)

    conn =
      :get
      |> conn("/users?id=42")
      |> run_plug(Plug.Parsers, parsers: [:urlencoded])
      |> run_plug(LoadResource, [])

    assert conn.private[:diplomat_resource] == %{id: 42}
  end

  test "fetches resource using plug configuration" do
    conn =
      :get
      |> conn("/users?id=1")
      |> run_plug(Plug.Parsers, parsers: [:urlencoded])
      |> run_plug(LoadResource, [resource_loader: TestLoader])

    assert conn.private[:diplomat_resource] == %{id: 1}
  end

  test "fetches missing resource" do
    conn =
      :get
      |> conn("/users?id=99")
      |> run_plug(Plug.Parsers, parsers: [:urlencoded])
      |> run_plug(LoadResource, [resource_loader: TestLoader, handler: TestErrorHandler])

    assert conn.private[:diplomat_resource] == nil
    assert conn.status == 404
  end
end
