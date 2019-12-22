# coffee/no-backticks

This rule disallows use of the backtick operator (for including snippets of JavaScript)

#### :-1: Examples of **incorrect** code for this rule:
```coffeescript
foo = `a`

class A
  `get b() {}`
```

#### :+1: Examples of **correct** code for this rule:
```coffeescript
foo = ->

"a#{b}`c`"
```
