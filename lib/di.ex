
defmodule Di do
  # di - for dependency injection


  defmacro __using__(_) do
    quote do
      Module.register_attribute __MODULE__, :di_functions,
        accumulate: true, persist: true
      import Di
      
    end
  end

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
    # Module.put_attribute(TryDi, :di_functions, info)
    Module.put_attribute(TryDi, :di_functions, :name)
    quote do
      # @di_functions unquote(info)
      def(unquote(head), unquote(body))
    end
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
    return 1
  end

  def t do
    # run TryDi, %{param_a: 5}
  end

end

