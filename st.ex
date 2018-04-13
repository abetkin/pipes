defmodule Struct.Vanilla do

  defmacro __using__(_e) do
    quote do
      def __struct__(kv) do
        kv |> Map.new
      end
    end
  end
end

defmodule S do
  use Struct.Vanilla
end