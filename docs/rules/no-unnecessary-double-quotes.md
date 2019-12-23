# coffee/no-unnecessary-double-quotes

This rule disallows the use of double quotes (`"`) for strings when single quotes (`'`) would suffice

#### :-1: Examples of **incorrect** code for this rule:

```coffeescript
###eslint coffee/no-unnecessary-double-quotes: "error"###

foo = "double"

foo = """
  doubleblock
"""
```

#### :+1: Examples of **correct** code for this rule:

```coffeescript
###eslint coffee/no-unnecessary-double-quotes: "error"###

foo = 'double'

foo = '''
  doubleblock
'''

interpolation = "inter#{polation}"

foo = """
  #{interpolation}foo
"""

singleQuote = "single'quote"

# always allow double quotes for directives
"use strict"
```
