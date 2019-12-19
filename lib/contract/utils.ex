defmodule Contract.Utils do
  def prepare_input(input, fields) do
    input
    |> Enum.map(fn
      {key, _value} when is_atom(key) ->
        {key, nil}

      {key, _value} when is_bitstring(key) ->
        key
        |> string_to_atom
        |> case do
          nil -> nil
          key -> {key, nil}
        end
    end)
    |> Enum.filter(fn
      nil ->
        nil

      {key, _value} = param ->
        ("#{key}" in fields)
        |> case do
          true -> param
          _ -> nil
        end
    end)
    |> Enum.into(%{})
  end

  def string_to_atom(value) do
    value
    |> String.to_existing_atom()
  rescue
    _ -> nil
  end
end
