defmodule Sheriff.Policy do
  @moduledoc """
  A basic behaviour for policies
  """

  @callback permitted?(map, {atom, String.t} | atom, map | nil) :: boolean()
end
