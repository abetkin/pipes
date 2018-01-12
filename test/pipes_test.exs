# TODO State const

defmodule Mod1 do

  def run do
    %{
      mod1: :mod1
    }
  end

end


defmodule Mod2 do
  
  @dep [Mod1]
  def run(mod1) do
    %{mod2: :mod2}
  end
end

defmodule Mod3 do
  
  @dep [Mod1]
  def run(mod1) do
    mod1.mod1
    %{mod3: :mod3}
  end
end



defmodule Main do

  @dep [Mod1, Mod2, Mod3]
  def run(mod1, mod2, mod3) do
    mod1 |> Map.merge(mod2)
    |> Map.merge(mod3)
  end
end


###


# deps, layers, mod -> Pipeline

defmodule PipesTest do
  use ExUnit.Case

  setup _ do
    %{
      pp: %Pipeline{
        get_deps: fn mod ->
          %{
            Mod1 => [],
            Mod2 => [Mod1],
            Mod3 => [Mod1],
            Main => [Mod1, Mod2, Mod3],
          }[mod]
        end, 
        layers: [
          [Mod1],
          [Mod2, Mod3],
        ],
      }
    }
  end

  test "all", %{pp: pp} do
    res = Pipeline.run(pp, Main, %{flag: true})
    assert res == %{mod1: :mod1, mod2: :mod2, mod3: :mod3}
  end

  test "fun layers", %{pp: pp} do
    fun_layers = Pipeline.get_fun_layers pp, Main
    assert Kernel.length(fun_layers) == Kernel.length(pp.layers)
  end


end

