# coffee/postfix-comprehension-assign-parens

This rule requires parentheses around potentially confusing assignments in postfix comprehensions

:wrench: The `--fix` option on the [command line](https://eslint.org/docs/user-guide/command-line-interface#fixing-problems)
can automatically fix the problems reported by this rule

#### :-1: Examples of **incorrect** code for this rule:

```coffeescript
###eslint coffee/postfix-comprehension-assign-parens###

x[key] = val for key, val of z

x += y for y from z

doubleIt = x * 2 for x in singles

x = y(food) for food in foods when food isnt 'chocolate'
```

#### :+1: Examples of **correct** code for this rule:

```coffeescript
###eslint coffee/postfix-comprehension-assign-parens###

(x[key] = val) for key, val of z

(x += y) for y from z

(doubleIt = x * 2) for x in singles

(x = y(food)) for food in foods when food isnt 'chocolate'

x = (y for y in z)

b = a(food for food in foods when food isnt 'chocolate')
```
