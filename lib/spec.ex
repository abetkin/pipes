
defmodule Dep do

  defmacro __using__(_options) do
    quote do
      import Dep
    end
  end

  defmacro dep a, b, c do
    IO.inspect a
    IO.puts "---"
    IO.inspect b
    IO.puts "---"
    IO.inspect c
    nil

  end

end


defmodule M do
  import Dep

  # dep [http: [params: [p: _] = params]] when p

  dep [http: [params: [p: _] = params], do:
    def name [:some | path] do
    end

end