
defmodule Di do
  # di - for dependency injection


  defmacro __using__(_) do
    quote do
      import Di
      @di_functions []
      @before_compile Di
      # @on_definition Di
    end
  end

  defmacro __before_compile__(env) do
    env.module |> IO.inspect(label: "a")
    Module.register_attribute env.module, :di_functions,
        accumulate: true, persist: true
  end

  # def __on_definition__(env, kind, name, args, guards, body) do
  #   import IEx
  #   IEx.pry
  # end

  def parse_arg {:=, _, [struct, var]} do
    var = elem(var, 0)
    %{
      struct: parse_arg(struct),
      var: var,
    }
  end
  
  def parse_arg {:%, _, [alias, map]} = struct do
    {:__aliases__, _, [struct]} = alias
    {:%{}, _, kv} = map
    # [a: {:a, [line: 77], nil}] = kv
    keys = for {k, v} <- kv do
      k
    end
    %{
      struct: {struct, keys}
    }
  end


  defmacro defdi(head, body) do
    info = parse_declaration(head)
    # Module.put_attribute(TryDi, :vsn, 11)
    # Module.put_attribute(TryDi, :di_functions, info)
    list = [:a, 2]
    quote do
      @di_functions unquote(list)
      def(unquote(head), unquote(body))
    end
    nil
  end

  defp parse_declaration(head) do
    {fun_name, _, args} = head
    args = for arg <- args do
      parse_arg(arg)
    end
    %{
      name: fun_name,
      args: args,
    }
  end

end


defmodule Params do
  defstruct [:a, :b] # TODO

  def run %{} = dic do
    for {k, v} <- dic |> Map.to_list do
      case k do
        "param_" <> k -> {k, v}
        # :param_ <> k -> {k, v}
        _ -> nil
      end
    end
    |> Enum.filter(fn x -> not is_nil(x) end)
    |> Map.new
    
  end
end

defmodule User do
  defstruct [:a, :b]

  def run %Params{} = p do
    if p.login == "me" and p.password == "myself" do
      %{name: "Thomas"}
    else
      %{}
    end
  end
end


defmodule TryDi do
  use Di
  
  defdi f(%Params{a: a}, %User{b: b}) do
    1
  end


end

