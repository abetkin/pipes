
defmodule Flatten do

  @max_repeat 3

  def flatten(node, fun) when is_function(fun) do
    opts = %{
      fun: fun,
      result: AppendList.new,
      repeat: 0,
    }
    nodes = fun.(node)
    flatten(nodes, opts)
  end

  def flatten([], %{result: result}) do
    result.list |> Enum.reverse
  end

  def flatten(list, %{repeat: repeat}) when repeat == @max_repeat do
    throw "Cycle deps"
  end

  def flatten(list, opts) when is_list(list) do
    result = opts.result |> AppendList.extend(list)
    repeat = if AppendList.same(result, opts.result) do
      opts.repeat + 1
    else
      opts.repeat
    end
    for node <- list do
      opts.fun.(node)
    end
    |> Enum.concat
    |> flatten(%{opts |
      result: result, repeat: repeat,
    })
  end

  # test

  def f(x) do
    case x do
      :a -> [:b, :c]
      :b -> [:c, :e]
      :e -> []
      :c -> [:e, :f]
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