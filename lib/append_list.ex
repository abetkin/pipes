defmodule AppendList do

  def new() do
    %{
      list: [], set: MapSet.new,
    }
  end

  def new(items) when is_list(items) do
    new |> extend(items)
  end

  def append(self, item) do
    new_set = self.set |> MapSet.put(item)
    if MapSet.size(new_set) != MapSet.size(self.set) do
      %{
        list: [item | self.list],
        set: new_set
      }
    else
      self
    end
  end

  def extend(self, items) do
    items |> Enum.reduce(self, fn item, acc -> 
      acc |> append(item)
    end)
  end

  def same(self, other) do
    self.list == other.list
  end
end