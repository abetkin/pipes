

defmodule Params1 do
  use Inject

  defstruct [:login, :password] # TODO


  def run(%InitialState{} = params) do
    for {k, v} <- Map.to_list(params) do
      k
      |> Atom.to_string
      |> case do
        "param_" <> key -> {key, v}
        _ -> nil
      end
    end
    |> Enum.filter(&(not is_nil(&1)))
    |> Map.new(fn {k, v} -> {k |> String.to_atom, v} end)
  end
end


defmodule User1 do
  use Inject


  def run(%Params1{} = p, %InitialState{} = raw) do
    p
    |> case do
      %{login: "me", password: "myself"} ->
        "Thomas"
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
    u = Inject.run(User1, %{
      param_login: "me",
      param_password: "myself",
    })
    assert u == "Thomas"

  end



end

