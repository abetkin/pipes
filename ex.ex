defmodule M do
  @main :main

  defdi main(%Raw{} = raw, %Ppln{ = p}) do
    p 
    |> f(some, args)
    |> f
    
  end

  defdi f(%Other{}) do
    
  end


  @pipe :debug

  defdi f(%Ppln.Global{} = p) do
    p |> Ppln.push(%{a: state})
    |> Ppln.debug(fn err -> end)
    |> some_f
    |> Ppln.pop([:pat, :h])
  end
end


#FIXME Ppln always
# exitstack