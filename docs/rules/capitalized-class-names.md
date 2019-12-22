# coffee/capitalized-class-names

This rule enforces that class names start with a capital letter

#### :-1: Examples of **incorrect** code for this rule:

```coffeescript
###eslint coffee/capitalized-class-names: "error"###

class animal

class Animals.boa
```

#### :+1: Examples of **correct** code for this rule:

```coffeescript
###eslint coffee/capitalized-class-names: "error"###

class Animal

class nested.Name
```
