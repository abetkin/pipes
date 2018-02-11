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


defmodule LoL do

  defstruct [:set, :list]

  def new do
    %{
      set: MapSet.new,
      list: []
    }
  end

  def new(items) do
    new |> add(items)
  end

  def add(self, items) when is_list(items) do
    new_set = MapSet.to_list(self.set) ++ items
    |> MapSet.new
    if MapSet.size(new_set) == MapSet.size(self.set) do
      self
    else
      dif = new_set |> MapSet.difference(self.set)
      if dif == MapSet.new([:b, :c]) do
        require IEx
        IEx.pry
      end
      items = items
      |> Enum.filter(fn i -> i in dif end)
      |> Enum.uniq
      %{
        set: new_set,
        list: [items | self.list]
      }
    end
  end

  def changed(rev1, rev2) do
    MapSet.size(rev1.set) == MapSet.size(rev2.set)
  end
end