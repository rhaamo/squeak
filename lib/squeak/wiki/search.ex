defmodule Squeak.Wiki.Search do
  @moduledoc """
  Implementation of the full-text wiki search
  """
  import Ecto.Query

  defp prefix_search(term), do: String.replace(term, ~r/\W/u, "") <> ":*"

  @spec run(Ecto.Query.t(), any()) :: Ecto.Query.t()
  def run(query, search_term) do
    where(
      query,
      fragment(
        "to_tsvector('english', content || ' ' ) @@
        to_tsquery(?)",
        ^prefix_search(search_term)
      )
    )
  end
end
