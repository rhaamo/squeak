defmodule Squeak.Namespaces.NamespaceTest do
  use Squeak.DataCase
  use EctoFixtures

  @tag fixtures: :namespaces
  test "test resolve_tree 1", %{data: _data} do
    a = Squeak.Namespaces.Namespace.resolve_tree(["ns_one"])
    assert length(a) == 1
    assert Enum.at(a, 0).name == "ns_one"
  end

  @tag fixtures: :namespaces
  test "test resolve_tree 1-2", %{data: _data} do
    a = Squeak.Namespaces.Namespace.resolve_tree(["ns_one", "ns_two"])
    assert length(a) == 2
    assert Enum.at(a, 0).name == "ns_one"
    assert Enum.at(a, 1).name == "ns_two"
  end

  @tag fixtures: :namespaces
  test "test resolve_tree 1-2-3", %{data: _data} do
    a = Squeak.Namespaces.Namespace.resolve_tree(["ns_one", "ns_two", "ns_three"])
    Enum.map(a, fn x ->
      IO.puts("x: " <> x.name)
    end)
    assert length(a) == 3
    assert Enum.at(a, 0).name == "ns_one"
    assert Enum.at(a, 1).name == "ns_two"
    assert Enum.at(a, 2).name == "ns_three"
  end

  @tag fixtures: :namespaces
  test "test resolve_tree 1-notfound", %{data: _data} do
    a = Squeak.Namespaces.Namespace.resolve_tree(["ns_one", "does_not_exists"])
    assert length(a) == 2
    assert Enum.at(a, 0).name == "ns_one"
    assert is_nil(Enum.at(a, 1))
  end

  @tag fixtures: :namespaces
  test "test resolve_tree 1-notfound-notfound", %{data: _data} do
    a = Squeak.Namespaces.Namespace.resolve_tree(["ns_one", "does_not_exists", "this_one_too"])
    assert length(a) == 2
    assert Enum.at(a, 0).name == "ns_one"
    assert is_nil(Enum.at(a, 1))
  end

  @tag fixtures: :namespaces
  test "test resolve_tree 1-2-notfound", %{data: _data} do
    a = Squeak.Namespaces.Namespace.resolve_tree(["ns_one", "ns_two", "does_not_exists"])
    assert length(a) == 3
    assert Enum.at(a, 0).name == "ns_one"
    assert Enum.at(a, 1).name == "ns_two"
    assert is_nil(Enum.at(a, 2))
  end

  @tag fixtures: :namespaces
  test "test resolve_tree 1-2-notfound-notfound", %{data: _data} do
    a = Squeak.Namespaces.Namespace.resolve_tree(["ns_one", "ns_two", "does_not_exists"])
    assert length(a) == 3
    assert Enum.at(a, 0).name == "ns_one"
    assert Enum.at(a, 1).name == "ns_two"
    assert is_nil(Enum.at(a, 2))
  end

  @tag fixtures: :namespaces
  test "test resolve_tree 1-2-3-notfound", %{data: _data} do
    a =
      Squeak.Namespaces.Namespace.resolve_tree(["ns_one", "ns_two", "ns_three", "does_not_exists"])

    assert length(a) == 4
    assert Enum.at(a, 0).name == "ns_one"
    assert Enum.at(a, 1).name == "ns_two"
    assert Enum.at(a, 2).name == "ns_three"
    assert is_nil(Enum.at(a, 3))
  end

  @tag fixtures: :namespaces
  test "test resolve_tree notfound", %{data: _data} do
    a = Squeak.Namespaces.Namespace.resolve_tree(["does_not_exists"])
    assert length(a) == 1
    assert is_nil(Enum.at(a, 0))
  end
end
