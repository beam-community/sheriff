defmodule Diplomat.Handler do
  @moduledoc false

  @callback resource_missing(Plug.Conn.t) :: Plug.Conn.t
  @callback unauthenticated(Plug.Conn.t) :: Plug.Conn.t
  @callback unauthorized(Plug.Conn.t) :: Plug.Conn.t
end
