
defmodule Resolver1 do
  #TODO Check for cycle deps should be done separately
  # hint: if new cycles don't give new modules
  
  # defstruct [
  #   :get_deps
  #   :modules,
  #   :layers,
  # ]

  def run mod, get_deps do
    %{
      modules: get_deps.(mod),
      get_deps: get_deps,
      result: [],
      processed: MapSet.new,
      failures: 0,
    }
    |> get_order
  end
  
  def get_order(%{modules: [], result: result}), do:
    result
    |> Enum.concat
    |> Enum.unique

  def get_order(%{failures: 3} = r) do
    IO.puts "resolved:"
    IO.inspect r.processed
    IO.puts "unresolved:"
    IO.inspect r.modules
    throw "Cyclic deps"
  end

  # dep in modules

  def get_order(%{modules: modules} = r) do
    # find modules without deps
    {resolvable, rest} = Enum.split_with(modules, fn m ->
      Kernel.length(r.get_deps.(m)) == 0
    end)
    # flatten the rest
    processed = case length(resolvable) do
      0 -> r.processed
      _ -> MapSet.new(MapSet.to_list(r.processed) ++ resolvable)
    end
    rest_deps = for m <- rest do
      r.get_deps.(m)
      |> Enum.filter(fn dep -> dep not in processed end)
    end
    |> Enum.concat
    r = %{r|processed: processed}
    modules = MapSet.new(rest_deps ++ rest)
    Resolver.get_order(r, resolvable, modules)
  end
  
  def get_order(r, [], rest) do
    Resolver.get_order %{r|
      modules: rest,
      failures: r.failures + 1
    }
  end

  def get_order(r, resolvable, rest) do
    Resolver.get_order %{r|
      result: [resolvable | r.result],
      modules: rest,
    }
  end


end


# defmodule Pipeline do

#   @doc """
  
#   """

  

#   defstruct [
#     :layers, # []
#     :get_deps, # fn mod -> [] end
    
#   ]



#   def get_fun_layers(%Pipeline{} = pp, mod) do
#     get_deps = fn
#       State -> []
#       mod -> pp.get_deps.(mod)
#     end
#     for layer <- pp.layers do
#       for mod <- layer do
#         fn state ->
#           args = for dep <- get_deps.(mod),
#             do: state[dep]
#           %{mod => apply(mod, :run, args)}
#         end
#       end
#     end
#   end

#   def eval_fun_layers(layers, state \\ %{})
#   def eval_fun_layers([], state), do: state
#   def eval_fun_layers(layers, state) do
#     [top | layers] = layers
#     res = for fun <- top, do: fun.(state)
#     res = for m <- res, {k, v} <- m,
#       do: {k, v},
#       into: %{}
#     res = case Map.size(state) > 0 do
#       true -> Map.merge(state, res)
#       false -> res
#     end
#     eval_fun_layers(layers, res)
#   end

#   def run(%Pipeline{} = pp, mod, state) do
#     state = pp |> get_fun_layers(mod)
#       |> eval_fun_layers(%{State => state})
#     args = for dep <- pp.get_deps.(mod),
#       do: state[dep]
#     apply(mod, :run, args)
#   end

# end