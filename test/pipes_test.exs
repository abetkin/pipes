defmodule Mod1 do

  def run do
    %{
      mod1: :mod1
    }
  end

end


defmodule Mod2 do
  
  @dep [State, Mod1]
  def run(state, mod1) do
    if state.flag do
      %{mod2: :mod2}
    else
      %{}
    end
  end

end




defmodule Main do

  @dep [Mod1, Mod2]
  def run(mod1, mod2) do
    Map.merge mod1, mod2
  end
end


####

# defmodule SimpleTest do
#   use ExUnit.Case

#     setup _ do
#       %{cache: %{
#         State => %{a: state}
#       }}
#     end

#     test "1", ctx do
#       assert ctx.a == :state
#     end


# end

defmodule PipesTest do
  use ExUnit.Case

  setup _ do
    %{
      get_deps: fn mod ->
        MAP = %{
          Mod1 => [],
          Mod2 => [Mod1]
        }
        MAP[mod]
      end, 
      layers: [
        [Mod1],
        [Mod2],
        [Main],
      ],
    }
  end

  test "all", ctx do
    run = M.build_pipeline ctx
    run.(M2, %{flag: true})
  end


end

