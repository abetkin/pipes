
defmodule Flatten do

  @max_iterations 1000

  def flatten(node, fun) when is_function(fun) do
    opts = %{
      fun: fun,
      result: [],
      iteration: 0,
    }
    nodes = fun.(node)
    flatten(nodes, opts)
  end

  def make(result) do
    result |> Enum.reduce(%{list: [], set: MapSet.new}, fn items, acc ->
      item = items |> MapSet.new |> MapSet.difference(acc.set)
      %{
        list: [item |> MapSet.to_list | acc.list],
        set: acc.set |> MapSet.union(item)
      }
    end)
  end

  def flatten([], %{result: result}) do
    # build result
    make(result).list |> Enum.reverse
  end

  def flatten(list, %{iteration: iteration}) when iteration == @max_iterations do
    throw "Cycle deps"
  end

  def flatten(list, opts) when is_list(list) do
    result = [list | opts.result] 
    for node <- list do
      opts.fun.(node)
    end
    |> Enum.concat
    |> flatten(%{opts |
      result: result, iteration: opts.iteration + 1,
    })
  end

  # test

  def f(x) do
    case x do
      :a -> [:b, :c, :e]
      :b -> [:f, :e]
      :e -> []
      :c -> [:f]
      :f -> []    
    end
  end



  def g(x) do
    case x do
      :a -> [:b, :c]
      :b -> [:c, :e]
      :e -> []
      :c -> [:e, :f]
      :f -> [:a]    
    end
  end


end