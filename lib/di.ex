
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

  def parse_arg {:%{}, _} do
    a
    |> IO.inspect
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
    args = args |> case do
      nil -> []
      _ -> 
        for arg <- args do
          parse_arg(arg)
        end
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
    Run.run(mod)
  end

end


defmodule Run do
  def run(mod) do
    layers = Flatten.flatten(mod, &get_deps/1)
    layers ++ [[mod]]
    |> get_state
    |> case do
      state -> state[mod]
    end
  end

  def get_deps(mod) do
    for attr <- mod.__info__(:attributes) do
      attr
      |> case do
        {:deps, v} -> v
        _ -> []
      end
    end
    |> Enum.concat
  end

  def get_state(layers) do
    layers |> Enum.reduce(%{}, fn deps, state ->
      state
      |> get_state(deps)
      |> Map.merge(state)
    end)
  end

  def get_state(state, deps) do
    for mod <- deps do
      args = get_args(mod, state)
      {mod, apply(mod, :run, args)}
    end
    |> Map.new
  end

  def get_args(mod, state) do
    for m <- get_deps(mod) do
      state[m]
    end
  end

end


