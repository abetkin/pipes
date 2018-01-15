defmodule State do
  # a marker
end

defmodule Compile do

  
  
  def get_layers(
    modules, get_deps, layers \\ nil, resolved \\ nil
  )
  def get_layers([], _, layers, _), do: layers
  def get_layers(
    modules, get_deps, layers, resolved
  ) do
    resolved = case resolved do
      nil -> MapSet.new [State]
      v -> v
    end
    modules = modules
    |> Enum.map(fn m ->
      deps = get_deps.(m)
      Enum.filter(deps, fn m -> m not in resolved end)
    end)
    |> List.flatten |> MapSet.new
    |> MapSet.union(MapSet.new modules)
    # get the next layer
    {layer, rest} = Enum.split_with(modules, fn mod ->
      deps = get_deps.(mod) |> MapSet.new
      MapSet.subset?(deps, resolved)
    end)
    resolved = layer |> MapSet.new |> MapSet.union(resolved)
    layers = case layers do
      nil -> [layer]
      _ -> [layer|layers]
    end
    get_layers(rest, get_deps, layers, resolved)
  end
    

end


defmodule Pipeline do

  @doc """
  
  """

  

  defstruct [
    :mod,
    :layers, # []
    :get_deps, # fn mod -> [] end
    
  ]



  def get_fun_layers(%Pipeline{} = pp, mod) do
    get_deps = fn
      State -> []
      mod -> pp.get_deps.(mod)
    end
    for layer <- pp.layers do
      for mod <- layer do
        fn state ->
          args = for dep <- get_deps.(mod),
            do: state[dep]
          %{mod => apply(mod, :run, args)}
        end
      end
    end
  end

  def eval_fun_layers(layers, state \\ %{})
  def eval_fun_layers([], state), do: state
  def eval_fun_layers(layers, state) do
    [top | layers] = layers
    res = for fun <- top, do: fun.(state)
    res = for m <- res, {k, v} <- m,
      do: {k, v},
      into: %{}
    res = case Map.size(state) > 0 do
      true -> Map.merge(state, res)
      false -> res
    end
    eval_fun_layers(layers, res)
  end

  def run(%Pipeline{} = pp, mod, state) do
    state = pp |> get_fun_layers(mod)
      |> eval_fun_layers(%{State => state})
    args = for dep <- pp.get_deps.(mod),
      do: state[dep]
    apply(mod, :run, args)
  end

end