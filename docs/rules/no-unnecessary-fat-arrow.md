# coffee/no-unnecessary-fat-arrow

This rule disallows the use of "fat arrows" (`=>`) when they are not necessary (i.e. the function body doesn't reference `this`/`@`)

#### :-1: Examples of **incorrect** code for this rule:

```coffeescript
###eslint coffee/no-unnecessary-fat-arrow: ["error"]###

=>

(b) =>
  -> b

class A
  b: => doSomething()
```

#### :+1: Examples of **correct** code for this rule:

```coffeescript
###eslint coffee/no-unnecessary-fat-arrow: ["error"]###

=> @doSomething()

(@b) =>

-> this

class A
  b: =>
    @c()
```
