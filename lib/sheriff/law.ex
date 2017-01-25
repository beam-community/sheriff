defmodule Sheriff.Law do
  @moduledoc """
  A basic behaviour for laws
  """

  @callback legal?(map, {atom, String.t} | atom, map | nil) :: boolean()
end
