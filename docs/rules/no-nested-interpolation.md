# coffee/no-nested-interpolation

This rule disallows nesting of string and/or heregex interpolations

#### :-1: Examples of **incorrect** code for this rule:

```coffeescript
###eslint coffee/no-nested-interpolation: "error"###

str = "Book by #{"#{firstName} #{lastName}".toUpperCase()}"

///
  ^
  #{"a#{b}"}
///
```

#### :+1: Examples of **correct** code for this rule:

```coffeescript
###eslint coffee/no-nested-interpolation: "error"###

"Book by #{firstName.toUpperCase()} #{lastName.toUpperCase()}"

///
  ^
  #{a}
///
```
