import Seedex

seed_once Squeak.Namespaces.Namespace, [:name], fn namespace ->
  namespace
  |> Map.put(:name, "meta")
end

seed_once Squeak.Wiki.Page, [:name], fn page ->
  namespace = Squeak.Namespaces.Namespace.get_by_name_and_parent_id_query("meta", nil) |> Squeak.Repo.one!
  page
  |> Map.put(:namespace, namespace)
  |> Map.put(:name, "about")
  |> Map.put(:content, File.read!("priv/seeds/meta_about.md"))
end
