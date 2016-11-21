defmodule Diplomat.Policy do
  @moduledoc """
  A basic behaviour for policies
  """

  @callback permitted?(map, {atom, String.t}, map | nil) :: boolean()
end
