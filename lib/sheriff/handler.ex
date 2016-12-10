defmodule Sheriff.Handler do
  @moduledoc """
  Handles the dispatch of requests for missing, unethenticated,
  and unauthorized requests in the pipeline with a simple setup
  of behaviours
  """

  @callback resource_missing(Plug.Conn.t) :: Plug.Conn.t
  @callback unauthenticated(Plug.Conn.t) :: Plug.Conn.t
  @callback unauthorized(Plug.Conn.t) :: Plug.Conn.t
end
