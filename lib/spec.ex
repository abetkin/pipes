

defmodule M do
  @moduledoc """
  
  requires and exports paths
  """

  @export """
  user
  """
  
  exp f, do:
    {:some, {:path}}

  co f(%{http: %{params: p}}) do
    # if f :flag, do: {:a, {:b, {:c}}}
    inspect 
    
  end

  def test do
    req {:http, :params}
  end

end