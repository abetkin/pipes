

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
    gql {:user, [a: :b]}
    # can be in the same namespace
  end

  dep %{http: params} do
    def [:some | path] do
    end
  end

end