

defmodule LayersTest do
  use ExUnit.Case

  # alias Pipeline.Compile, as: Compile 

  setup _ do
    %{
        get_deps: fn mod ->
          %{
            :State => [],
            :Mod1 => [],
            :Mod2 => [:Mod1],
            :Mod3 => [:Mod2],
            :Main => [:Mod1, :Mod2, :Mod3],
          }[mod]
        end, 
      }
  end

  # test "main", %{get_deps: get_deps} do
  #   modules = [:Mod1, :Main]
  #   layers = Resolver.run(:Main, get_deps)
  #   assert layers == [[:Main], [:Mod3], [:Mod2], [:Mod1]]
  # end

  test "simple" do
    get_deps = fn mod ->
      %{
        a: [:b],
        b: [:c],
        c: [],
      }[mod]
    end
    # 
    Flattener.flatten(:a, get_deps)
    |> IO.inspect
  end

  # test "cycle deps" do
  #   get_deps = fn mod ->
  #     %{
  #       a: [:b],
  #       b: [:a],
  #     }[mod]
  #   end
  #   # 
  #   catch_error(
  #       Flattener.flatten(:a, get_deps)
  #   )
  # end


end

