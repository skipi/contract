defmodule Contract.Context do
  use Ecto.Schema

  embedded_schema do
    field(:__input, :map, default: %{})

    field(:__cast_rules, :map, default: %{})
    field(:__cast_output, :map, default: %{})
    field(:__cast_errors, :map, default: nil)

    field(:__validation_rules, {:array, :map}, default: [])
    field(:__validation_output, :map, default: %{})
    field(:__validation_errors, :map, default: nil)

    field(:__valid?, :boolean, default: true)
    field(:__output, :map, default: %{})
  end

  def new() do
    %__MODULE__{
      id: Ecto.UUID.generate()
    }
  end

  def run(context, data) do
    context
    |> set_input(data)
    |> run_casts()
    |> run_validations()
    |> resolve()
  end

  def resolve(context) do
    context
  end

  def run_casts(context) do
    Contract.Cast.run(context.__input, context.__cast_rules)
    |> case do
      {:ok, casted_input} ->
        context
        |> set_cast_output(casted_input)

      {:error, errors} ->
        context
        |> set_cast_errors(errors)
    end
  end

  def run_validations(context) do
    Contract.Validate.run(context.__cast_output, context.__validation_rules)
    |> case do
      {:ok, validated_input} ->
        context
        |> set_validation_output(validated_input)

      {:error, errors} ->
        context
        |> set_validation_errors(errors)
    end
  end

  def set_input(context, input) do
    %{context | __input: input}
  end

  def set_cast_output(context, cast_output) do
    %{context | __cast_output: cast_output}
  end

  def set_validation_output(context, validation_output) do
    %{context | __validation_output: validation_output}
  end

  def set_validation_errors(context, errors) do
    %{context | __validation_errors: errors}
  end

  def set_cast_errors(context, errors) do
    %{context | __cast_errors: errors}
  end

  def set_output(context, output) do
    %{context | __output: output}
  end

  def set_invalid(context) do
    %{context | __valid?: false}
  end

  def set_valid(context) do
    %{context | __valid?: true}
  end

  def add_cast(context, field, type) do
    cast_rules =
      context.__cast_rules
      |> Map.put(field, type)

    %{context | __cast_rules: cast_rules}
  end

  def add_validation(context, field, validation) do
    validation_rules = context.__validation_rules ++ [{field, validation}]

    %{context | __validation_rules: validation_rules}
  end
end
