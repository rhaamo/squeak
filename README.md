# Squeak

Squeak is a something-something blog and wiki engine, with some specific features for hackers/makers/whatevers.

Features (not exhaustive and some might still be planned):
- Blog posts (markdown, with Enhanced™️ editor)
- Blog posts import (with frontmatter block)
- Medias manager with namespacing support
- Medias manager handles everything, images are resized to 4 different sizes (thumb, small, medium, large)
- Wiki pages (markdown, with Enhanced™️ editor)
- Wiki pages handles namespacing with `:`
- Builtin gopher server serving blog and wiki pages
- A wiki page can be tagged "hw equipment", enabling a separate, linked, sheet with summary information specs and a changelog editor

## Install

- git clone
- cd
- mix deps.get
- mix compile
- cp config/sample.secret.exs config/prod.secret.exs
- mix ecto.migrate
- mix seedex.seed
- mix phx.server
- enjoy

## Cli commands

```
mix help squeak.user
mix help squeak.post
```

## Contact

Dashie: fluffy @ otter dot sh

## License

AGPL 3