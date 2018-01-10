

defmodule RD do
  def eval([], cache) do cache end

  def eval(layers, cache \\ %{}) do
    [top | layers] = layers
    res = Enum.map top, fn fun ->
      fun.(cache)
    end
    res = for m <- res, {k, v} <- m,
      into: %{},
      do: {k, v}
    cache = Map.merge(res, cache)
    eval(layers, cache)
  end

end