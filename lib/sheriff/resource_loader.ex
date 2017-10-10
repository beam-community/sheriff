defmodule Sheriff.ResourceLoader do
  @moduledoc """
  A module to load a resource given its role and action
  """

  @callback fetch_resource({atom, String.t()}, map) :: {:ok, term} | {:error, String.t()}
end
