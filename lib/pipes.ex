
# not used

defmodule Pipeline do

  def run(mod, state) do
    
  end

  def get_modules(mod) do
    n = :rand.uniform(2)
    case n do
      1 -> [Mod1]
      _ -> [Mod1, Mod2]
    end
  end

end


