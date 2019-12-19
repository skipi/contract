defmodule Contract.Cast do
  alias Contract.Utils

  def run(input, casts) do
    type_keys = casts |> Map.keys() |> Enum.map(&"#{&1}")

    {Utils.prepare_input(input, type_keys), casts}
    |> Ecto.Changeset.cast(input, Map.keys(casts))
    |> case do
      %{valid?: true} = changeset ->
        casted_output = changeset |> Ecto.Changeset.apply_changes()
        {:ok, casted_output}

      changeset ->
        cast_errors =
          changeset.errors
          |> Enum.reduce([], fn {casted_field, _error}, errors ->
            [{casted_field, :invalid} | errors]
          end)

        {:error, cast_errors}
    end
  end
end
