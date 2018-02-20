

defmodule DiTest do
  use ExUnit.Case

  # alias Pipeline.Compile, as: Compile 

  setup _ do
    %{}
  end

  test "simple" do
    assert Di.run(TryDi) == "Thomas"
    
  end



end

