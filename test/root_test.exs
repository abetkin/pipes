

defmodule Params1 do
  use Di
  alias Di.Raw, as: Raw
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


defmodule User1 do
  use Di
  alias Di.Raw, as: Raw

  defdi run(%Params1{} = p, %Raw{} = raw) do
    raw
    |> case do
      %{login: login, password: password} ->
        %Params1{login: login, password: password}
      _ -> nil
    end
  end

end


defmodule RootTest do
  use ExUnit.Case

  setup _ do
    %{}
  end

  test "simple" do
    u = Di.run(User1, %{
      params_login: "me",
      param_password: "myself",
    })
    assert u == "Thomas"
    
  end



end

