


defmodule Params1 do
  alias Di.Raw, as: Raw
  use Di
  
  defstruct [:login, :password] # TODO


  defdi run(%Raw{} = params) do
    for {k, v} <- Map.to_list(params) do
      k
      |> IO.inspect(label: "k")
      |> case do
        # :"param_" <> key -> {key, v}
        "param_" <> key -> {key, v}
        _ -> nil
      end
    end
    |> Enum.filter(&(not is_nil(&1)))
    |> Map.new
  end
end

defmodule A.B.C do
  use Di
  
  defdi run do
    1
  end
end


defmodule User1 do
  alias Di.Raw, as: Raw
  use Di
  

  defdi run(%Params1{} = p, %Raw{} = raw, %A.B.C{} = abc) do
    raw
    |> case do
      %{login: login, password: password} ->
        %Params1{login: login, password: password}
      _ -> nil
    end
  end

end


defmodule LayersTest do
  use ExUnit.Case
  alias Di.Raw, as: Raw

  setup _ do
    %{}
  end

  test "1" do
    get_deps = &Run.get_deps/1
    Flatten.flatten(TryDi, get_deps, [Raw])
    |> case do
      [[Params], [User]] -> :ok
    end
  end

  test "2" do
    get_deps = &Run.get_deps/1
    Flatten.flatten(User1, get_deps, [Raw])
    |> case do
      [[Params1]] -> :ok
    end
  end


    
end

