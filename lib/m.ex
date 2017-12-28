

defmodule M do
    

    def main do
        # hanfle 1 mod
        # split into layers
        state = %{
            State: %{a: 1},
            M1: %{b: 2},
        }
        eval = [State]
        li = [State, M1, M2, X]
        fn m ->
            #
        end


        l1 = [State]
        l2 = [Mod1]
        l3 = [Mod2]
    end

    def eval(mod, mod_deps, state) do
        deps = mod_deps[mod]
        |> Enum.map(fn d -> state[d] end)
        # Execute the "run" method
        apply(mod, :run, deps)
    end

    def f(layers, mod_deps \\ %{
        Mod1: [State],
    }) do
        # mod_deps is a const (map)
        layers = [top | down_layers]
        state = {}
        # accumulate state, reduce
        process_layer = fn layer ->
            Enum.map layer, fn m ->
                eval(m, mod_deps, state)
            end
        end
    end

    # def f do
    #     [1, 3, 4]
    #     |> Enum.filter(fn m ->
    #         m != 3
    #     end)
    #     |> Enum.map(fn e -> e end)
    # end
end