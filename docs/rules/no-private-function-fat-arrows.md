# coffee/no-private-function-fat-arrows

This rule disallows using fat arrows (`=>`) for "private" functions in class bodies since they have no effect

#### :-1: Examples of **incorrect** code for this rule:

```coffeescript
###eslint coffee/no-private-function-fat-arrows: "error"###

class Foo
  foo = =>
  foo()
  
class Bar
  foo = ->
    class
      foo = =>
```

#### :+1: Examples of **correct** code for this rule:

```coffeescript
###eslint coffee/no-private-function-fat-arrows: "error"###

class Foo
  foo = ->
  foo()
  
class Foo
  foo: =>

class Foo
  foo: ->
    bar = =>
    bar()
```
