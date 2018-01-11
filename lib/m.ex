

defmodule M do
  require IEx

  @doc """
  
  """
  
  #TODO
  def eval_mod(mod, deps, cache) do
    args = Enum.map get_deps.(mod), fn dep ->
        cache[dep]
    end
    apply(mod, :run, args)
  end

  def run(mod, state, %{get_deps: get_deps, layers: layers}) do
    eval_mod = fn mod, cache ->
        args = Enum.map get_deps.(mod), fn dep ->
            cache[dep]
        end
        apply(mod, :run, args)
    end
    fun_layers = for layer <- layers, mod <- layer do
        &(%{mod => eval_mod.(mod, &1)})
    end
    IO.puts "fun_layers"
    # IEx.pry
    RD.eval fun_layers, %{State => state}
  end

  def build_pipeline(%{get_deps: get_deps, layers: layers} = config) do
    # config for now:
    fn mod, state ->
        run(mod, state, config)
    end
  end

end