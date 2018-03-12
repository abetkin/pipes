defmodule Meta do
  defmacro __using__(_) do
    quote do
      import Meta
    end
  end
  
  # defmacro mydef(head, body, x) do
  defmacro mydef(head, body) do
    {head, body} |> IO.inspect(label: :macro)
    nil
  end
end


defmodule M do
  use Meta

  # mydef f(a) when a > 1 do
  #   a
  # end

  def f(a), inject(%{} = jh, %{} = y)  when jh > y do
    a
  end

  def g, inject(%Pipe{} = pp) do
    pp |> f(1)
  end

  def h do
    %Ctx{flag: true}
  end

  def on_error %SomeError{} = err do
    
  end

  def k, inject(%Pipe{} = pp) do
    pp |> f(1)
    |> Pipe.on_error(fn err ->
    end)
    |> g()
  end

  test "1" do
    pp |> Pp.run(g, [])
  end 
  # eq
  # def f(ctx) do
  #   g = get(ctx, G)
  #   (fn %{inner: g} ->
  #   end).(g)

  #   pp |> f(a, b)
  # end
end