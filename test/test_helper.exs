

defmodule Params do
  use Di
  defstruct [:login, :password] # TODO

  # def run %{} = dic do
  #   for {k, v} <- dic |> Map.to_list do
  #     case k do
  #       "param_" <> k -> {k, v}
  #       # :param_ <> k -> {k, v}
  #       _ -> nil
  #     end
  #   end
  #   |> Enum.filter(fn x -> not is_nil(x) end)
  #   |> Map.new
  # end

  defdi run do
    %Params{login: "me", password: "myself"}
  end
end

defmodule User do
  use Di
  defstruct [:name]

  defdi run %Params{} = p do
    if p.login == "me" and p.password == "myself" do
      %User{name: "Thomas"}
    else
      %{}
    end
  end
 
end


defmodule TryDi do
  use Di

  defdi run(%User{} = u) do
    u.name
  end

  #TODO make defdi optional 
end



ExUnit.start()
