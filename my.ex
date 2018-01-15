

defmodule A do
  
  defmacro extra(v) do
    IO.inspect v
    unquote(1)
  end

end