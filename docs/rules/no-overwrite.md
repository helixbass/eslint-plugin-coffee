# coffee/no-overwrite

This rule disallows modifying (i.e. reassigning) variables that have already been assigned in the same or an outer scope

### Inline allowing comment syntax

By preceding e.g. an assignment `=` with a `###:###`/`###:=###` comment (mimicking an imagined `:=` modifying-assignment syntax), you
can indicate that a reassignment should be allowed

#### :-1: Examples of **incorrect** code for this rule:

```coffeescript
###eslint coffee/no-overwrite: "error"###

a = 1
->
  a = 2
  
a = 1
class B
  c: ->
    a = 2
    
a = 1
->
  for a in b
    c()
```

#### :+1: Examples of **correct** code for this rule:

```coffeescript
###eslint coffee/no-overwrite: "error"###

a = 1
a = 2 unless b

if x
  a = 1
else
  a = 2

a = 1
(a) ->
  a = 2
  
a = 1
->
  a ###:###= 2
  
a = 1
->
  for ###:=### a in b
    c()
```

### Options

This rule has an object option which defaults to:
```
{
  "allowSameScope": true,
  "allowNullInitializers": true
}
```

#### allowSameScope

By default, this rule only disallows modifying variables from an outer scope. When using the `"allowSameScope": false` option,
it also disallows modifying variables from the same scope, effectively disallowing *all* reassignment

#### :+1: Examples of **correct** code for this rule with the default `"allowSameScope": true` option:

```coffeescript
###eslint coffee/no-overwrite: ["error", {"allowSameScope": true}]###

a = 1
a = 2
    
a = 1
for a in b
  c()
```

#### :-1: Examples of **incorrect** code for this rule with the `"allowSameScope": false` option:

```coffeescript
###eslint coffee/no-overwrite: ["error", {"allowSameScope": false}]###

a = 1
a = 2
    
a = 1
for a in b
  c()
```

#### :+1: Examples of **correct** code for this rule with the `"allowSameScope": false` option:

```coffeescript
###eslint coffee/no-overwrite: ["error", {"allowSameScope": false}]###

a = 1
a ###:###= 2
    
a = 1
for ###:=### a in b
  c()
```

#### allowNullInitializers

By default, this rule allows reassignment to a variable that has been "null-initialized" (e.g. `a = null`).
When using the `"allowNullInitializers": false` option, it disallows this

#### :+1: Examples of **correct** code for this rule with the default `"allowNullInitializers": true` option:

```coffeescript
###eslint coffee/no-overwrite: ["error", {"allowNullInitializers": true}]###

a = null
->
  a = 1
    
a = null
->
  for a in b
    c()
```

#### :-1: Examples of **incorrect** code for this rule with the `"allowNullInitializers": false` option:

```coffeescript
###eslint coffee/no-overwrite: ["error", {"allowNullInitializers": false}]###

a = null
->
  a = 1
    
a = null
->
  for a in b
    c()
```
