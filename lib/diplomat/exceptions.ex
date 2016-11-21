defmodule Diplomat.NotPermittedError do
  defexception message: "not sufficient privilege", plug_status: 403
end
