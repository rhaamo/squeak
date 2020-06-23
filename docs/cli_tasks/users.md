# mix squeak.user list

List all users

# mix squeak.user new <email> <username> <options>

Create a new user.

Options:
  - password (string)
  - admin (boolean)

Ex:

```
mix squeak.user new aaa@example.com aaa --admin --password="foo"
```

```
mix squeak.user new bbb@example.com bbb --no-admin --password="foo"
```

# mix squeak.user set <username> <options>

Set a flag for a specific user.

Options:
  - admin (boolean)

Ex:

```
mix squeak.user set aaa --admin
```


```
mix squeak.user set aaa --no-admin
```
