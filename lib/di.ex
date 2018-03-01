defmodule Di.InitialState do
  defstruct []
end

defmodule Di do
  # def - for dependency injection

  defmacro __using__(_) do
    quote do
      import Kernel, except: [def: 2]
      import Di
      # FIXME rm attribute
      Module.register_attribute __MODULE__, :main, persist: true
      @main :run


      Module.register_attribute __MODULE__, :di,
        accumulate: true
      Module.register_attribute __MODULE__, :deps,
        accumulate: true, persist: true
      @before_compile Di
      
      
    end
  end

  def __before_compile__(env) do
    info = env.module |> Module.get_attribute(:di)
    deps = for fun <- info do
      for arg <- fun.args do
        %{struct: {aliases, _}} = arg
        get_module(aliases, env)
      end
    end
    |> Enum.concat
    Module.put_attribute(env.module, :deps, deps)
  end

  def is_struct(mod) do
    mod |> Map.from_struct |> Map.keys |> case do
      [] -> false
      _ -> true
    end
  end

  # TODO do this at compile time only
  def get_module(aliases, env) do
    aliases = for al <- aliases do
      al |> Atom.to_string
    end
    [name | aliases] = aliases
    env.aliases 
    |> Enum.filter(fn {al, mod} ->
      [al_name] = al |> Module.split
      al_name == name
    end)
    |> case do
      [{name, mod}] ->
        mod |> Module.split
      _ -> [name]
    end
    |> Enum.concat(aliases)
    |> Module.concat
end

  def parse_arg {:=, arg_opts, [struct, var]} = arg do
    """
    -> {new_arg, parsed_arg}
    """
    {new_struct, parsed} = parse_arg(struct)
    parsed = parsed |> Map.put(:var, elem(var, 0))
    new_arg = {:=, arg_opts, [new_struct, var]}
    {new_arg, parsed}
  end
  
  def parse_arg {:%, _, [alias, inner_map]} = arg do
    {:__aliases__, _, aliases} = alias
    mod = aliases |> get_module(__ENV__)
    {:%{}, _, kv} = inner_map
    # [a: {:a, [line: 77], nil}] = kv
    keys = for {k, v} <- kv do
      k
    end
    new_arg = mod |> is_struct 
    |> if do
      arg
    else
      inner_map
    end
    {new_arg, %{
      struct: {aliases, keys}
      #TODO rename
    }}
  end

  defmacro def(head, body) do
    {new_head, parsed} = parse_declaration(head)

    quote do
      @di unquote(parsed |> Macro.escape)
      Kernel.def(unquote(new_head), unquote(body))
    end
  end

  defp parse_declaration(head) do
    {fun_name, fun_opts, args} = head
    {new_args, parsed_args} = args |> case do
      nil -> {nil, []}
      _ -> 
        for arg <- args do
          parse_arg(arg)
        end
        |> Enum.unzip
    end
    parsed = %{
      name: fun_name,
      args: parsed_args,
    }
    new_head = {fun_name, fun_opts, new_args}
    {new_head, parsed}
  end

  # def run(mod, dic) do
  def run(mod, state \\ %{}) do
    Run.run(mod, state)
  end

end


defmodule Run do
  

  def run(mod) do
    mod |> run(%{})
  end

  # def run(InitialState, state) do
  #   state[InitialState]
  # end

  def run(mod, state) do
    layers = Flatten.flatten(mod, &get_deps/1, [Pipeline, InitialState])

    state = %{
      InitialState => state,
    }
    state = get_state(%{
      layers: layers ++ [[mod]],
      state: state,
    })
    state[mod]
  end

  def get_deps(Pipeline), do: []
  def get_deps(InitialState), do: []

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

  def get_state(%{layers: layers, state: init_state} = opts) do
    layers |> Enum.reduce(init_state, fn deps, state ->
      %{state: state, deps: deps}
      |> get_state
      |> Map.merge(state)
    end)
  end

  def get_state(%{state: state, deps: deps} = g) do
    for mod <- deps do
      # args = get_args(mod, state)
      args = for m <- get_deps(mod) do
        get_struct(m, state)
      end
      value = state |> Map.has_key?(mod)
      |> if do
        state[mod]
      else
        main = mod.__info__(:attributes)
        |> Enum.map(fn
          {:main, [v]} -> v
          _ -> nil
        end)
        |> Enum.find(fn x -> x end)
        apply(mod, main, args)
      end
      {mod, value}
    end
    |> Map.new
  end

  def get_struct Pipeline, state do
    %Pipeline{components: state}
  end

  def get_struct InitialState, state do
    state[InitialState]
  end

  def get_struct(m, state) do
    state[m] |> Map.put(:__struct__, m)
  end

end