defmodule State do
  # a marker
end

defmodule Resolver do
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
      ordered: [],
      failures: 0,
    }
    |> get_order
  end
  
  def get_order(%{modules: [], ordered: ordered}), do:
    ordered
    |> MapSet.new
    |> MapSet.to_list
  # def get_layers %Resolver{} = r do
  #   # resolved = case resolved do
  #   #   nil -> MapSet.new [State]
  #   #   v -> v
  #   # end
  #   modules = r.modules
  #   |> Enum.map(fn m ->
  #     deps = get_deps.(m)
  #     Enum.filter(deps, fn m -> m in r.modules end)
  #   end)
  #   |> List.flatten |> MapSet.new
  #   |> MapSet.union(MapSet.new modules)
  #   # get the next layer
  #   {layer, rest} = Enum.split_with(modules, fn mod ->
  #     deps = get_deps.(mod) |> MapSet.new
  #     MapSet.subset?(deps, resolved)
  #   end)
  #   resolved = layer |> MapSet.new |> MapSet.union(resolved)
  #   layers = case layers do
  #     nil -> [layer]
  #     _ -> [layer|layers]
  #   end
  #   get_layers(rest, get_deps, layers, resolved)
  # end
  
  # def get_order(%{result: result}) when length(result) > 3 do
  #   get_order %{r|
  #     result: Enum.concat(result)
  #   }
  # end

  # TODO mapset as ordered

  def get_order(%{failures: 3} = r) do
    throw r.modules
  end

  def get_order(%{modules: modules} = r) do
    # find modules without deps
    {resolvable, rest} = Enum.split_with(modules, fn m ->
      Kernel.length(r.get_deps.(m)) == 0
    end)
    # flatten the rest
    ordered = case length(resolvable) do
      0 -> r.ordered
      _ -> r.ordered ++ resolvable
    end
    rest_deps = for m <- rest do
      r.get_deps.(m)
    end |> Enum.concat
    |> Enum.filter(fn m ->
      m not in ordered
    end)
    new_modules = MapSet.new(rest_deps ++ rest)
    r = %{r|ordered: ordered}
    #TODO
    Resolver.get_order(r, resolvable, new_modules)
  end
  
  def get_order(r, [], rest) do
    Resolver.get_order %{r|
      modules: rest,
      failures: r.failures + 1
    }
  end

  def get_order(r, resolvable, rest) do
    # flatten the rest
    ordered = r.ordered ++ resolvable
    rest_deps = for m <- rest do
      r.get_deps.(m)
    end |> Enum.concat
    |> Enum.filter(fn m ->
      m not in r.ordered
    end)
    Resolver.get_order %{r|
      ordered: ,
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