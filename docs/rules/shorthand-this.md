# coffee/shorthand-this

This rule enforces or disallows use of `@` vs `this`

### Options

This rule has two options: the first is a string option that can be `"always"`, `"never"` or `"allow"`. The second is an
object option whose default value is:
```
{
  forbidStandalone: false
}
```

#### :-1: Examples of **incorrect** code for this rule with the default `"always"` option:

```coffeescript
###eslint coffee/shorthand-this: ["error", "always"]###

->
  return this

a = this.b
```

#### :+1: Examples of **correct** code for this rule with the default `"always"` option:

```coffeescript
###eslint coffee/shorthand-this: ["error", "always"]###

->
  return @

a = @b

(@a) ->
```

#### :-1: Examples of **incorrect** code for this rule with the `"never"` option:

```coffeescript
###eslint coffee/shorthand-this: ["error", "never"]###

->
  return @

a = @b
```

#### :+1: Examples of **correct** code for this rule with the `"never"` option:

```coffeescript
###eslint coffee/shorthand-this: ["error", "never"]###

->
  return this

a = this.b

(@a) ->
```

#### forbidStandalone

If you want to allow (or enforce) usage of e.g. `@prop` but disallow usage of "standalone" `@`, you can use the
`"forbidStandalone": true` option (possibly in combination with the `"allow"` option, which by itself permits all
use of `@` and/or `this` so won't flag any violations)

#### :-1: Examples of **incorrect** code for this rule with the `"allow"` and `"forbidStandalone": true` options:

```coffeescript
###eslint coffee/shorthand-this: ["error", "allow", {"forbidStandalone": true}]###

->
  return @

doSomething(@)
```

#### :+1: Examples of **correct** code for this rule with the `"allow"` and `"forbidStandalone": true` options:

```coffeescript
###eslint coffee/shorthand-this: ["error", "allow", {"forbidStandalone": true}]###

->
  return this

doSomething(this)

a = this.b

a = @b
```

#### :-1: Examples of **incorrect** code for this rule with the `"always"` and `"forbidStandalone": true` options:

```coffeescript
###eslint coffee/shorthand-this: ["error", "always", {"forbidStandalone": true}]###

->
  return @

doSomething(@)

a = this.b
```

#### :+1: Examples of **correct** code for this rule with the `"always"` and `"forbidStandalone": true` options:

```coffeescript
###eslint coffee/shorthand-this: ["error", "always", {"forbidStandalone": true}]###

->
  return this

doSomething(this)

a = @b
```
