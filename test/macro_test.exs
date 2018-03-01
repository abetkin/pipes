
defmodule A1 do
  defstruct []
  use Di

  def run do
    :A
  end
end

defmodule B1 do
  defstruct []
  use Di

  def run %A1{} = a do
    a = :A
  end
end


defmodule MacroTest do
  use ExUnit.Case

  test "1" do
    A1.__info__(:attributes)
    |> Map.new
    |> Map.get(:deps)
    |> case do [] -> :ok end

    B1.__info__(:attributes)
    |> Map.new
    |> Map.get(:deps)
    |> case do [A1] -> :ok end
  end

  # test "2" do
    
  # end
    
end

