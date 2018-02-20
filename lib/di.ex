defmodule Di.Raw do
  defstruct []
end

defmodule Di do
  # di - for dependency injection

  

  defmacro __using__(_) do
    quote do
      alias Di.Raw, as: Raw
      import Di
      
      Module.register_attribute __MODULE__, :defdi,
        accumulate: true
      Module.register_attribute __MODULE__, :deps,
        accumulate: true, persist: true
      @before_compile Di
      
    end
  end

  def __before_compile__(env) do
    env |> IO.inspect(label: :env)
    info = env.module |> Module.get_attribute(:defdi)
    deps = for fun <- info do
      for arg <- fun.args do
        %{struct: {mod_name, _}} = arg
        arg |> IO.inspect(label: :arg)
        Module.concat([mod_name])
      end
    end
    |> Enum.concat
    Module.put_attribute(env.module, :deps, deps)
  end

  def get_module(aliases, env) do
    [name | _] = aliases
    env.aliases
    |> Enum.map(fn al_name, mod ->
      [al_name] = al |> Module.split
      al_name == name
    end)
    |> case do
      [{name, mod}] ->
        mod |> Module.split
        |> Enum.concat(aliases)
        #TODO
      _ -> Module.concat(aliases)
    end
  end

  def parse_arg {:=, _, [struct, var]} do
    var = elem(var, 0)
    parse_arg(struct)
    |> Map.put(:var, var)
  end
  
  def parse_arg {:%, _, [alias, map]} = struct do
    {:__aliases__, _, aliases} = alias
    struct = get_module(aliases, env)
    {:%{}, _, kv} = map
    # [a: {:a, [line: 77], nil}] = kv
    keys = for {k, v} <- kv do
      k
    end
    %{
      struct: {struct, keys}
    }
  end

  # def parse_arg {:%{}, _} do
  #   a
  #   |> IO.inspect
  # end

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

  # def run(mod, dic) do
  def run(mod, state \\ %{}) do
    Run.run(mod, state)
  end

end


defmodule Run do
  alias Di.Raw, as: Raw

  def run(mod) do
    mod
    |> run(%{})
  end

  def run(mod, state) do
    layers = Flatten.flatten(mod, &get_deps/1, [[Raw]])
    layers
    |> IO.inspect(label: :lrs)
    state = %{
      Raw => state,
    }
    %{
      layers: layers ++ [[mod]],
      state: state,
    }
    |> get_state
    |> case do
      state -> state[mod]
    end
  end

  def get_deps(Raw), do: []

  def get_deps(mod) do
    # mod = Module.split(mod) |> List.last
    # |> case do
    #   "Raw" ->
    #     import IEx; IEx.pry
    #     []
    #   _ -> mod
    # end

    for attr <- mod.__info__(:attributes) do
      attr
      |> case do
        {:deps, v} -> v
        _ -> []
      end
    end
    |> Enum.concat

    # rescue _ ->
    #   import IEx
    #   IEx.pry
    # end
  end

  def get_state(%{layers: layers, state: init_state} = opts) do
    layers |> Enum.reduce(init_state, fn deps, state ->
      %{state: state, deps: deps}
      |> get_state
      |> Map.merge(state)
    end)
  end

  def get_state(%{state: state, deps: deps}) do
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


