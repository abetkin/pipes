
defmodule Inject do
  # def - for dependency injection

  defmacro __using__(_) do
    quote do
      import Kernel, except: [def: 2]
      import Inject
    end
  end

#   def __before_compile__(env) do
#     info = env.module |> Module.get_attribute(:di)
#     deps = for fun <- info do
#       for arg <- fun.args do
#         %{struct: {aliases, _}} = arg
#         get_module(aliases, env)
#       end
#     end
#     |> Enum.concat
#     Module.put_attribute(env.module, :deps, deps)
#   end

#   def is_struct(mod) do
#     mod |> Map.from_struct |> Map.keys |> case do
#       [] -> false
#       _ -> true
#     end
#   end

#   # TODO do this at compile time only
#   def get_module(aliases, env) do
#     aliases = for al <- aliases do
#       al |> Atom.to_string
#     end
#     [name | aliases] = aliases
#     env.aliases 
#     |> Enum.filter(fn {al, mod} ->
#       [al_name] = al |> Module.split
#       al_name == name
#     end)
#     |> case do
#       [{name, mod}] ->
#         mod |> Module.split
#       _ -> [name]
#     end
#     |> Enum.concat(aliases)
#     |> Module.concat
# end

#   def parse_arg {:=, arg_opts, [struct, var]} = arg do
#     """
#     -> {new_arg, parsed_arg}
#     """
#     {new_struct, parsed} = parse_arg(struct)
#     parsed = parsed |> Map.put(:var, elem(var, 0))
#     new_arg = {:=, arg_opts, [new_struct, var]}
#     {new_arg, parsed}
#   end
  
#   def parse_arg {:%, _, [alias, inner_map]} = arg do
#     {:__aliases__, _, aliases} = alias
#     mod = aliases |> get_module(__ENV__)
#     {:%{}, _, kv} = inner_map
#     # [a: {:a, [line: 77], nil}] = kv
#     keys = for {k, v} <- kv do
#       k
#     end
#     new_arg = mod |> is_struct 
#     |> if do
#       arg
#     else
#       inner_map
#     end
#     {new_arg, %{
#       struct: {aliases, keys}
#       #TODO rename
#     }}
#   end

  defmacro def(head, body) do
    {head, body} |> IO.inspect
    import IEx
    IEx.pry
    nil
  end

  defmacro def(head, body, els) do
    {head, body, els} |> IO.inspect(lbl: :els)
    import IEx
    IEx.pry
    nil
  end

  # defp parse_declaration(head) do
  #   {fun_name, fun_opts, args} = head
  #   {new_args, parsed_args} = args |> case do
  #     nil -> {nil, []}
  #     _ -> 
  #       for arg <- args do
  #         parse_arg(arg)
  #       end
  #       |> Enum.unzip
  #   end
  #   parsed = %{
  #     name: fun_name,
  #     args: parsed_args,
  #   }
  #   new_head = {fun_name, fun_opts, new_args}
  #   {new_head, parsed}
  # end


end
