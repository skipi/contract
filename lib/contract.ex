defmodule Contract do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:__contexts, {:array, Contract.Context}, default: [])
    # field(:__casts, {:array, :term}, default: [])
    # field(:__cast_errors, {:array, :term}, default: :not_set)
    # field(:__casted?, :boolean, default: false)

    # field(:__validations, {:array, :term}, default: [])
    # field(:__validation_errors, {:array, :term}, default: :not_set)
    # field(:__validated?, :boolean, default: false)
  end

  def fulfill(contract, data) do
    {_contract, output} =
      contract.__contexts
      |> Enum.reduce({contract, data}, fn context, {contract, data} ->
        context =
          context
          |> Contract.Context.run(data)

        {put_context(contract, context), context.__output}
      end)
      |> IO.inspect()
  end

  def add_cast(contract, key, cast) do
    context =
      contract
      |> current_context
      |> Contract.Context.add_cast(key, cast)

    contract
    |> put_context(context)
  end

  def add_validation(contract, key, validation) do
    context =
      contract
      |> current_context
      |> Contract.Context.add_validation(key, validation)

    contract
    |> put_context(context)
  end

  def put_context(%{__contexts: []} = contract, context) do
    contract
    |> set_contexts([context])
  end

  def put_context(contract, %{id: context_id} = context) do
    contexts =
      contract.__contexts
      |> Enum.find(&(&1.id == context_id))
      |> case do
        nil ->
          contract.__contexts ++ [context]

        _context ->
          contract.__contexts
          |> Enum.map(fn
            %{id: ^context_id} -> context
            context -> context
          end)
      end

    contract
    |> set_contexts(contexts)
  end

  def set_contexts(contract, contexts) do
    %{contract | __contexts: contexts}
  end

  def set_input(contract, input) do
    contexts =
      contract
      |> current_context
      |> Contract.Context.set_input(input)

    contract
    |> set_contexts(contexts)
  end

  def current_context(%{__contexts: []}) do
    Contract.Context.new()
  end

  def current_context(%{__contexts: contexts}) do
    contexts
    |> Enum.reverse()
    |> Enum.find(fn context ->
      nil
    end)
  end

  # def add_cast(contract, key, cast) do
  #   %{contract | __casts: [{key, cast} | contract.__casts]}
  # end

  # def add_validation(contract, key, validation) do
  #   %{contract | __validations: [{key, validation} | contract.__validations]}
  # end

  # def set_input(contract, input) do
  #   %{contract | __input: input}
  # end

  # def set_cast_output(contract, casted_output) do
  #   %{contract | __cast_output: casted_output}
  # end

  # def set_cast_errors(contract, cast_errors) do
  #   %{contract | __cast_errors: cast_errors}
  #   |> set_cast_output(:error)
  # end

  # def apply_cast(contract) do
  #   Contract.Cast.run(contract)
  # end

  # def apply_validation(contract) do
  #   Contract.Validate.run(contract)
  # end

  # def casts(contract) do
  #   contract.__casts
  #   |> Enum.into(%{})
  # end
end
