


defmodule Comp do
  use Di

  di run %Pipeline{} = pp do
    pp |> Pipeline.get_initial |> case do
      %{"a" => "b"} -> :ok
    end
  end
end


defmodule PipelineTest do
  use ExUnit.Case

  test "1" do
    Comp
    |> Pipeline.run(%{"a" => "b"})
    |> case do
      :ok -> :ok
    end
  end

    
end

