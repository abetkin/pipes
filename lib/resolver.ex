
defmodule Flattener do
  def flatten(node, get_children) when is_function(get_children) do
    opts = %{
      get_children: get_children,
      iteration: 0,
    }
    flatten(node, opts)
  end

  def flatten([], _opts) do
    []
  end

  def flatten(_r, list) when is_list(list) do
    for item <- list do
      item
    end
  end

  def flatten(r, mod) do
    r.get_deps.(mod)
    |> flatten
  end

end


defmodule Resolver do

  # TODO a way to prevent cycle deps

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
    for m <- modules do
      case m do
        is_list(m)
      end
      r.get_deps.(m)
    end
    
  end

  def flatten(_r, []) do
    []
  end

  def flatten(_r, list) when is_list(list) do
    list
    |> Enum.map(flatten)
  end

  def flatten(r, mod) do
    r.get_deps.(mod)
    |> flatten
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

