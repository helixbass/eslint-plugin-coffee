# coffee/empty-func-parens

This rule enforces or disallows the use of parentheses when defining a function with an empty parameter list

### Options

This rule has a string option:
```
"coffee/empty-func-parens": ["error", "never"]
```

- `"never"` (default) disallows parentheses for empty parameter lists
- `"always"` requires parentheses for empty parameter lists

#### :-1: Examples of **incorrect** code for this rule with the default `"never"` option:

```coffeescript
###eslint coffee/empty-func-parens: ["error", "never"]###

() ->

() =>
  doSomething()
  
class A
  b: () ->
    c()
```

#### :+1: Examples of **correct** code for this rule with the default `"never"` option:

```coffeescript
###eslint coffee/empty-func-parens: ["error", "never"]###

->

=>
  doSomething()
  
class A
  b: ->
    c()

(a) -> a + 1
```

#### :-1: Examples of **incorrect** code for this rule with the `"always"` option:

```coffeescript
###eslint coffee/empty-func-parens: ["error", "always"]###

->

=>
  doSomething()
  
class A
  b: ->
    c()
```

#### :+1: Examples of **correct** code for this rule with the `"always"` option:

```coffeescript
###eslint coffee/empty-func-parens: ["error", "always"]###

() ->

() =>
  doSomething()
  
class A
  b: () ->
    c()
    
(a) -> a + 1
```
