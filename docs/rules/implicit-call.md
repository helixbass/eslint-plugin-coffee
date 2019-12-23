# coffee/implicit-call

This rule disallows the use of implicit function calls (i.e. without function call parentheses `(`/`)`)

#### :-1: Examples of **incorrect** code for this rule:

```coffeescript
###eslint coffee/implicit-call: "error"###

f a

f
  a: 1
  b: 2
  
new A b
```

#### :+1: Examples of **correct** code for this rule:

```coffeescript
###eslint coffee/implicit-call: "error"###

f(a)

f(
  a: 1
  b: 2
)
  
new A(b)

new A
```
