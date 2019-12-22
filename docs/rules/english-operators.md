# coffee/english-operators

This rule enforces or disallows the use of "English" operators

### Options

This rule has a string option:
```
"coffee/english-operators": ["error", "always"]
```
- `"always"` (default) requires use of English operators
- `"never"` disallows use of English operators

#### :-1: Examples of **incorrect** code for this rule with the default `"always"` option:
```coffeescript
###eslint coffee/english-operators: ["error", "always"]###

a && b

a || b

a == b

a != b

!a
```

#### :+1: Examples of **correct** code for this rule with the default `"always"` option:
```coffeescript
###eslint coffee/english-operators: ["error", "always"]###

a and b

a or b

a is b

a isnt b

not a

!!a
```

#### :-1: Examples of **incorrect** code for this rule with the `"never"` option:
```coffeescript
###eslint coffee/english-operators: ["error", "never"]###

a and b

a or b

a is b

a isnt b

not a
```

#### :+1: Examples of **correct** code for this rule with the `"never"` option:
```coffeescript
###eslint coffee/english-operators: ["error", "never"]###

a && b

a || b

a == b

a != b

!a

!!a
```
