defmodule InitialState do
  defstruct []
end

defmodule Pipeline do
  defstruct [
    components: %{}
  ]

  def run mod, state do
    Run.run mod, state
  end

  def get_initial %Pipeline{components: %{InitialState => initial_state}} do
    initial_state
  end

end