
defmodule Injection do
  def main do
    :result
  end
end


defmodule Def1 do
  use Inject

  def f1, inject(%Injection{} = i) do
    i.key
  end

  def f2({a, :b}), inject(%Injection{x: x}) do
    x
  end

  def f3(a), inject(%Injection{} = b) when a + b < 1 do
    b
  end

  """
  <=>
  def f3(%Pipeline{injections: {Injection: b}} = pp, a) when ...
    b
  end
  """
  end
end


defmodule DiTest do
  use ExUnit.Case


  test "simple" do
    assert Inject.run(TryDi) == "Thomas"

  end





end
