defmodule Macros do

  defmacro __using__(_) do
    quote do
      # import Kernel, except: [def: 2]
      import Macros
    end
  end

  defmacro def(head, {:inject, _, args_list}, body) do
    args_list |> IO.inspect(label: :body)
    nil
  end

  defmacro def(
    head,
    {:when, _line, [inject, con]},
    body
  ) do
    con |> IO.inspect(label: :cond)
    nil
  end

end



defmodule M do
  use Macros

  def f(3, a, 4), inject(%AComp{x: x} = c, oth, er) when a + x < 5 do
    23
  end

  def f(a, b) do
    a + b
  end

  def g, inject(%A{}, %B{}) do
    a
  end
end


# pln |> M.f(3, 4, 4)
M.f(3, 5)
|> IO.inspect(label: "f")
