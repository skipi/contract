defmodule Contract.ContextTest do
  use ExUnit.Case

  doctest Contract
  alias Contract.Context

  describe "methods" do
    setup do
      context = Context.new()

      [
        context: context
      ]
    end

    test "creating context" do
      assert %Contract.Context{id: _} = Context.new()
    end

    test "setting input", %{context: context} do
      context =
        context
        |> Context.set_input(%{"foo" => "bar"})

      input = context.__input
      assert input == %{"foo" => "bar"}
    end

    test "adding casts", %{context: context} do
      context =
        context
        |> Context.add_cast(:id, :integer)
        |> Context.add_cast(:name, :string)

      cast_rules = context.__cast_rules

      assert cast_rules == %{
               id: :integer,
               name: :string
             }
    end

    test "adding validations", %{context: context} do
      id_validator = fn id ->
        cond do
          id > 1 and id < 10 -> {:ok, id}
          true -> :error
        end
      end

      name_min_validator = fn name ->
        length(name)
        |> case do
          str_len when str_len >= 1 -> {:ok, name}
          _ -> {:error, :too_short}
        end
      end

      name_max_validator = fn name ->
        length(name)
        |> case do
          str_len when str_len < 20 -> {:ok, name}
          _ -> {:error, :too_long}
        end
      end

      context =
        context
        |> Context.add_validation(:id, &id_validator.(&1))
        |> Context.add_validation(:name, &name_min_validator.(&1))
        |> Context.add_validation(:name, &name_max_validator.(&1))

      validation_rules = context.__validation_rules |> Enum.map(fn {key, _} -> key end)

      assert validation_rules == [:id, :name, :name]
    end
  end
end
