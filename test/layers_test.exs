
defmodule A do
  #TODO
  defstruct []
  use Inject

  def run do

  end
end

defmodule B do
  use Inject

  defstruct []

  def run %A{} do

  end
end

defmodule C do
  use Inject

  defstruct []

  def run %A{} = a, %B{} = b do

  end
end

defmodule D do
  use Inject

  defstruct []

  def run %C{} = c do

  end
end


defmodule LayersTest do
  use ExUnit.Case


  setup _ do
    %{}
  end

  test "1" do
    get_deps = &Run.get_deps/1
    Flatten.flatten(D, get_deps, [A, B])
    |> case do
      [[C]] -> :ok
    end
  end


end

