defmodule ContractTest do
  use ExUnit.Case

  doctest Contract
  import Contract

  @tag :wip
  test "test" do
    id_validator = fn id ->
      id
      |> case do
        id when 1 < id or id < 10 -> {:ok, id}
        _ -> {:error, :not_in_range}
      end
    end

    %Contract{}
    |> Contract.add_cast(:id, :integer)
    |> Contract.add_cast(:name, :string)
    |> Contract.add_validation(:id, &id_validator.(&1))
    |> Contract.add_validation(:name, {:length_min, 10})
    |> Contract.add_validation(:name, {:length_max, 10})
    |> Contract.add_validation(:id, :required)
    |> Contract.add_validation(:name, :required)
    |> Contract.fulfill(%{
      "id" => "1",
      "name" => "Stefan"
    })
  end

  describe "methods" do
    setup do
      [
        contract: %Contract{}
      ]
    end

    test "add cast", %{contract: contract} do
      contract =
        contract
        |> Contract.add_cast(:id, :integer)
        |> Contract.add_cast(:name, :integer)

      context =
        contract
        |> Contract.current_context()

      casts = context.__cast_rules

      assert casts == %{id: :integer, name: :integer}
    end

    test "add validation", %{contract: contract} do
      contract =
        contract
        |> Contract.add_validation(:id, :required)
        |> Contract.add_validation(:name, :required)

      context =
        contract
        |> Contract.current_context()

      validations = context.__validation_rules

      assert validations == [id: :required, name: :required]
    end

    test "current context", %{contract: contract} do
      contract =
        contract
        |> Contract.add_cast(:id, :integer)
        |> Contract.add_validation(:id, :required)

      assert length(contract.__contexts) == 1
    end

    test "fulfill", %{contract: contract} do
      atom_data = %{id: 1}
      string_data = %{"id" => 1}

      contract =
        contract
        |> Contract.add_cast(:id, :integer)
        |> Contract.add_validation(:id, :required)

      assert {:ok, %{id: 1}} = Contract.fulfill(contract, atom_data)
      assert {:ok, %{id: 1}} = Contract.fulfill(contract, string_data)
    end
  end

  # describe "casting" do
  #   setup _context do
  #     contract =
  #       Contract.cast(%{
  #         id: :integer,
  #         name: :string
  #       })
  #       |> Contract.validate(%{
  #         id: fn id ->
  #           cond do
  #             id > 1 -> {:ok, id}
  #             id < 10 -> {:ok, id}
  #             true -> {:error, :wrong_range}
  #           end
  #         end,
  #         name: [length_min: 10, length_max: 20]
  #       })

  #     %{
  #       contract: contract
  #     }
  #   end

  #   test "basic functionality", context do
  #     res =
  #       context.contract
  #       |> Contract.fulfill(%{
  #         id: 1,
  #         name: "Zbyszek"
  #       })
  #       |> Contract.agreement()

  #     assert {:ok, contract} = res
  #     assert contract = %{id: 1, name: "Zbyszek"}
  #   end

  #   test "error handling", context do
  #     res =
  #       context.contract
  #       |> Contract.fulfill(%{
  #         id: "Test"
  #       })
  #       |> Contract.aggreement()

  #     assert {:error, contract} = res

  #     errors = Contract.errors(contract)

  #     assert errors = %{
  #              cast: %{
  #                id: :invalid
  #              }
  #            }
  #   end
  # end
end
