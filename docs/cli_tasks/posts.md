# mix squeak.post import <username> <options>

Import posts from the `import/` folder. `draft` option set them all draft or `no-draft`.

Files needs to have `.md` extension.

Options:
  - draft (boolean)

Ex:

```
mix squeak.post import foo --draft
```

```
mix squeak.post import bar --no-draft
```

Sample frontmatter block:
```
  ---
  title: How to squeak
  tags: tag1, tag2, hello
  date: 2017-04-09
  license: CC-BY-SA
  ---
  Now is the blog post content page
  Notes:
  license field is not yet handled
```