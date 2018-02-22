defmodule Di.Raw do
  defstruct []
end

defmodule Di do
  # di - for dependency injection

  alias Di.Raw, as: Raw #?
  

  defmacro __using__(_) do
    quote do
      @main :run
      alias Di.Raw, as: Raw
      import Di
      # FIXME rm attribute
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
    parsed |> IO.inspect(label: :parsed)
    parsed = parsed |> Map.put(:var, elem(var, 0))
    new_arg = {:=, arg_opts, [new_struct, var]}
    {new_arg, parsed}
  end
  
  def parse_arg {:%, _, [alias, inner_map]} = arg do
    {:__aliases__, _, aliases} = alias
    mod = aliases |> get_module(__ENV__)
    mod |> Module.split
    |> IO.inspect(label: :mod)
    |> case do
      ["Di"] -> import IEx; IEx.pry
      _o -> _o
    end
    {:%{}, _, kv} = inner_map
    # [a: {:a, [line: 77], nil}] = kv
    keys = for {k, v} <- kv do
      k
    end
    new_arg = mod |> is_struct |> case do
      true -> arg
      false -> inner_map
    end
    {new_arg, %{
      struct: {aliases, keys}
      #TODO rename
    }}
  end

  defmacro defdi(head, body) do
    {new_head, parsed} = parse_declaration(head)

    quote do
      @defdi unquote(parsed |> Macro.escape)
      def(unquote(new_head), unquote(body))
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
  alias Di.Raw, as: Raw

  def run(mod) do
    mod |> run(%{})
  end

  def run(Raw, state) do
    state[Raw]
  end

  def run(mod, state) do
    layers = Flatten.flatten(mod, &get_deps/1, [[Raw]])
    layers
    state = %{
      Raw => state,
    }
    state = get_state(%{
      layers: layers ++ [[mod]],
      state: state,
    })
    state[mod]
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
      value = state |> Map.has_key?(mod)
      |> if do
        state[mod]
      else
        #FIXME
        main = @main |> if do
          @main
        else
          :run
        end
        apply(mod, main, args)
      end
      {mod, value}
    end
    |> Map.new
  end

  def get_args(mod, state) do
    for m <- get_deps(mod) do
      state[m]
      |> Map.put(:__struct__, m)
    end
  end

end