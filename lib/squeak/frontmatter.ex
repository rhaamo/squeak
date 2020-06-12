defmodule Squeak.Frontmatter do
  defp parse(content) do
    content
    |> String.split(~r/\n-{3,}\n/, parts: 2)
  end

  defp parse_yaml(frontmatter) do
    case YamlElixir.read_from_string(frontmatter) do
      {:ok, yaml} -> yaml
      {:error, _error} -> nil
    end
  end

  defp process([frontmatter, markdown]) do
    [parse_yaml(frontmatter), markdown]
  end

  def handle(content) do
    content
    |> parse
    |> process
  end
end
