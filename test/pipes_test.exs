
defmodule State do
  @doc "a marker"
end


# defmodule Mod1 do
#   require Pipeline


#   def run do
#     1
#   end

# end


# defmodule Mod2 do
  
#   @dep Mod1
#   def run(mod1) do
#     1
#   end

# end





# defmodule Pipes do
#   use Pipeline


#   @dep [Mod1, Mod2]
#   def run(mod1, mod2) do
#     Map.merge mod1, mod2
#   end
# end


####

defmodule PipesTest do
  use ExUnit.Case

  # test "simplest pipeline" do
  #   #TODO doctest! 
  #   r = Pipeline.run Pipes, %{initial: "data"}
  #   assert r == %{
  #     processed: "data",
  #     extra: "bit"
  #   }
  # end

    setup _ do
      %{cache: %{
        State => %{a: state}
      }}
    end

    test "1", ctx do
      assert ctx.a == :state
    end


end

