

defmodule M do
    
    def run(mod, state, %{get_deps: get_deps, layers: layers}) do
        eval_mod = fn mod, cache ->
            args = Enum.map get_deps.(mod), fn dep ->
                cache[dep]
            end
            apply(mod, :run, args)
        end
        eval_mod

    end

    def build_pipeline(%{get_deps: get_deps, layers: layers} = config) do
        # config for now:
        fn mod, state ->
            run(mod, state, config)
        end
    end
    
    # def api do
    #     run = build_pipeline get_deps
    #     run Mod, %{a: :state} 
    # end
end