defmodule Contract.Validate do
  def run(input, validations) do
    validations
    |> Enum.reduce([], fn {key, validation}, results ->
      value =
        input
        |> Map.get(key, :not_set)

      [{key, validate(validation, value)} | results]
    end)
    |> Enum.reduce({%{}, %{}}, fn {key, {response, value}}, {valid, invalid} ->
      {response, value}
      |> case do
        {:ok, value} ->
          {Map.put_new(valid, key, value), invalid}

        {:error, error} ->
          {valid, Map.put_new(invalid, key, error)}
      end
    end)
    |> case do
      {valid_map, invalid_map} when invalid_map == %{} ->
        {:ok, valid_map}

      {_, invalid_map} ->
        {:error, invalid_map}
    end
  end

  def validate(:required, value) do
    (value in [nil, :not_set, ""])
    |> case do
      true -> {:error, :is_required}
      false -> {:ok, value}
    end
  end

  def validate({:length_min, min}, value) when is_bitstring(value) do
    (String.length(value) < min)
    |> case do
      true -> {:error, :is_too_short}
      false -> {:ok, value}
    end
  end

  def validate({:length_min, min}, value) do
    (length(value) < min)
    |> case do
      true -> {:error, :is_too_short}
      false -> {:ok, value}
    end
  end

  def validate({:length_max, max}, value) when is_bitstring(value) do
    (String.length(value) > max)
    |> case do
      true -> {:error, :is_too_long}
      false -> {:ok, value}
    end
  end

  def validate({:length_max, max}, value) do
    (length(value) > max)
    |> case do
      true -> {:error, :is_too_long}
      false -> {:ok, value}
    end
  end

  def validate(fun, value) when is_function(fun, 1) do
    fun.(value)
  end
end
