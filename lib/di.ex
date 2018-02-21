defmodule Di.Raw do
  defstruct [
    :param_login,
    :param_password,
  ]
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

  def parse_arg {:=, _, [struct, var]} do
    var = elem(var, 0)
    parse_arg(struct)
    |> Map.put(:var, var)
  end
  
  def parse_arg {:%, _, [alias, map]} = struct do
    {:__aliases__, _, aliases} = alias
    # struct = get_module(aliases, env)
    {:%{}, _, kv} = map
    # [a: {:a, [line: 77], nil}] = kv
    keys = for {k, v} <- kv do
      k
    end
    %{
      struct: {aliases, keys}
      #TODO rename
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
      state |> Map.has_key?(mod)
      value = if state |> Map.has_key?(mod) do
        state[mod]
      else
        apply(mod, :run, args)
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


