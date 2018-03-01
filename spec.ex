def m %Pipe{prev: prev} = pp do
  prev
end

defmodule Test2 do
  defmodule Util do end

  def delete %Pipeline{} = pp, %User{} = u, %Perm{delete: can_delete} do
    # what |> means in this method's context
    # pp.meaning
    pp |> method()
    |> can_delete
    |> main
  end

  defmodule Error do end

  def util do
    if 1 do
      %Util{}
    else
      %Other.Error{}
  end

  def main(%Pipeline{ret: :ok}, %Util{}) do
    1
  end


end