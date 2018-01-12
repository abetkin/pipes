

defmodule Pipeline do
  # require IEx

  @doc """
  
  """

  defstruct [
    :get_deps, # fn mod -> [] end
    :layers, # []
  ]

  def get_fun_layers(%Pipeline{} = pp, mod) do
    for layer <- pp.layers do
      for mod <- layer do
        fn state ->
          args = for dep <- pp.get_deps.(mod),
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