

# defmodule M1 do
#   use Inject

#   def f, inject(%Component{} = c) do
#     1
#   end

#   def g(l) when is_list(l), inject(%Params{p: p}) when p == 1 do
#     2
#   end

# end


defmodule Cmp do
  use Inject

  # def inject(y) do
  #   1
  # end

  def f(x), inject(y) do
    2
  end
  
end