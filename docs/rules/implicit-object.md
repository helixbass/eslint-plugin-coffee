# coffee/implicit-object

This rule disallows the use of implicit objects (i.e. objects that don't have enclosing curly braces `{`/`}`)

### Options

This rule has two options: the first is a string option that currently only has the value `"never"`.
The second is an object option whose default value is:
```
{
  "allowOwnLine": false
}
```

#### allowOwnLine

By default, this rule disallows *all* implicit objects. When using the `"allowOwnLine": true` option, it allows implicit
objects as long as they are written on their "own line" in the source code

#### :-1: Examples of **incorrect** code for this rule with the default `"allowOwnLine": false` option:
```
###eslint coffee/implicit-object: ["error", "never", {"allowOwnLine": false}]###

a: 1

f a: 1, b: 2

f
  a: 1
  b: 2
  
x =
  a: ->
  b: 2
```

#### :+1: Examples of **correct** code for this rule with the default `"allowOwnLine": false` option:
```
###eslint coffee/implicit-object: ["error", "never", {"allowOwnLine": false}]###

{
  a: 1
  b: 2
}

f {a: 1, b: 2}

class A
  a: 1
  b: ->

x = {
  a: ->
  b: 2
}
```

#### :-1: Examples of **incorrect** code for this rule with the `"allowOwnLine": true` option:
```
###eslint coffee/implicit-object: ["error", "never", {"allowOwnLine": true}]###

f a: 1, b: 2

x = a: 1
```

#### :+1: Examples of **correct** code for this rule with the `"allowOwnLine": true` option:
```
###eslint coffee/implicit-object: ["error", "never", {"allowOwnLine": true}]###

a: 1
b: 2

f
  a: 1
  b: 2

f(
  a: 1
  b: 2
)

x =
  a: ->
  b: 2
```
