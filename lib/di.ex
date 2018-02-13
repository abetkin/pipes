
defmodule Di do
  # di - for dependency injection


  defmacro __using__(_) do
    quote do
      import Di
      Module.register_attribute __MODULE__, :defdi,
        accumulate: true
      Module.register_attribute __MODULE__, :deps,
        accumulate: true, persist: true
      @before_compile Di
      
    end
  end

  def __before_compile__(env) do
    info = env.module |> Module.get_attribute(:defdi)
    deps = for fun <- info do
      for arg <- fun.args do
        %{struct: {mod_name, _}} = arg
        Module.concat([mod_name])
      end
    end
    |> Enum.concat
    Module.put_attribute(env.module, :deps, deps)
  end

  def parse_arg {:=, _, [struct, var]} do
    var = elem(var, 0)
    parse_arg(struct)
    |> Map.put(:var, var)
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

    quote do
      @defdi unquote(info |> Macro.escape)
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

  def get_deps(mod) do
    for attr <- mod.__info__(:attributes) do
      case attr do
        {:deps, v} -> v
        _ -> []
      end
    end
    |> Enum.concat
  end

  # def run(mod, dic) do
  def run(mod) do
    
    layers = Flatten.flatten(mod, &get_deps/1)
    for deps <- layers do
      #TODO
    end
  end

  def build_args(mod, state, get_deps) do
    for mod <- get_deps.(mod) do
      state[mod]
    end
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
  
  # defdi f(%Params{a: a}, %User{b: b}) do
  #   1
  # end

  defdi run(%User{} = u) do
    u.name
  end



  # def t do
  #   run TryDi, %{"param_login" => "me", "param_password" => "myself"}
  # end
end

