

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

# defmodule A.B.C do

#   defmodule E.D.F do
    
#   end
  
# end


# defmodule GetModule do
#   use ExUnit.Case
#   alias A.B.C, as: ABC

#   test "1" do
#     Di.get
#   end

# end