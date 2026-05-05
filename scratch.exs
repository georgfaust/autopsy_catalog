e = AutopsyCatalog.get()
j = Jason.encode!(e, pretty: true)
from_j = Jason.decode!(j, keys: :atoms)

defmodule Diff do
  def find(e, j, path \\ [])
  
  def find(e, j, path) when is_list(e) and is_list(j) do
    if length(e) != length(j) do
      IO.puts("List length mismatch at #{inspect(path)}: #{length(e)} != #{length(j)}")
    else
      Enum.zip(e, j)
      |> Enum.with_index()
      |> Enum.each(fn {{ev, jv}, i} -> find(ev, jv, path ++ [i]) end)
    end
  end

  def find(%{} = e, %{} = j, path) do
    if is_struct(e) do
      IO.puts("Struct found at #{inspect(path)}: #{inspect(e.__struct__)}")
    end
    
    e_keys = Map.keys(e) |> Enum.reject(&(&1 == :__struct__)) |> Enum.sort()
    j_keys = Map.keys(j) |> Enum.reject(&(&1 == :__struct__)) |> Enum.sort()
    
    if e_keys != j_keys do
      IO.puts("Keys mismatch at #{inspect(path)}")
      IO.puts("E keys: #{inspect(e_keys)}")
      IO.puts("J keys: #{inspect(j_keys)}")
    else
      Enum.each(e_keys, fn k ->
        find(Map.get(e, k), Map.get(j, k), path ++ [k])
      end)
    end
  end

  def find(e, j, path) when e != j do
    IO.puts("Value mismatch at #{inspect(path)}:")
    IO.puts("E value (type #{inspect(type_of(e))}): #{inspect(e)}")
    IO.puts("J value (type #{inspect(type_of(j))}): #{inspect(j)}")
  end

  def find(_, _, _), do: :ok
  
  defp type_of(v) when is_binary(v), do: :binary
  defp type_of(v) when is_atom(v), do: :atom
  defp type_of(v) when is_integer(v), do: :integer
  defp type_of(v) when is_float(v), do: :float
  defp type_of(v) when is_list(v), do: :list
  defp type_of(v) when is_map(v), do: :map
  defp type_of(v) when is_tuple(v), do: :tuple
  defp type_of(_), do: :unknown
end

Diff.find(e, from_j)
