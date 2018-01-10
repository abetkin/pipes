

defmodule FunTest do
  use ExUnit.Case

  setup _ do
    %{layers: [
      l1, l2, 
    ]}
  end

  def l1, do:
    [fn _ ->
      %{1 => 2}
    end]
  
  def l2, do:
    [fn state ->
      for {k, v} <- Map.to_list(state), into: %{}, do: {k + 2, v + 2}
    end]

  def result, do:
    %{1 => 2, 3 => 4}

  test "1", ctx do
    got = RD.eval ctx.layers
    assert got == result
  end

end