defmodule Sheriff.NotPermittedError do
  @moduledoc """
  A module to handle a lack of permissions for a given request
  """
  defexception message: "not sufficient privilege", plug_status: 403
end
