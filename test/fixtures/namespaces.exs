ns model: Squeak.Namespaces.Namespace, repo: Squeak.Repo do
  ns_one do
    name "ns_one"
  end
  ns_two do
    name "ns_two"
    parent ns.ns_one
  end
  ns_three do
    name "ns_three"
    parent ns.ns_two
  end
end
