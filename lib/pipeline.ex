defmodule State do
  # a marker
end

defmodule Pipeline.Compile do
  # compile time
  def get_layers(mod, get_deps, resolved, els) do
    start = [State]
    lr0 = for mod <- all_modules do
      get_deps.(mod)
    end
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

  def eval_fun_layers([], state) do state end

  def eval_fun_layers(layers, state \\ %{}) do
    [top | layers] = layers
    res = for fun <- top, do: fun.(state)
    res = for m <- res, {k, v} <- m,
      do: {k, v},
      into: %{}
    if Map.size(state) > 0 do
      res = Map.merge(state, res)
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