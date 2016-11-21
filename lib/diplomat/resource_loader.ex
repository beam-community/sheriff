defmodule Diplomat.ResourceLoader do
  @moduledoc """
  """

  @callback fetch_resource({atom, String.t}, map) :: {:ok, term} | {:error, String.t}
end
