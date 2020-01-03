# coffee/boolean-keywords

This rule requires or disallows usage of specific boolean keywords

:wrench: The `--fix` option on the [command line](https://eslint.org/docs/user-guide/command-line-interface#fixing-problems)
can automatically fix some of the problems reported by this rule.

### Options

This rule has a required object option:

```js
"coffee/boolean-keywords": ["error", {"allow": ["yes", "no"]}]
```

Either:
- "allow": a list of which boolean keywords are allowed
- "disallow": a list of which boolean keywords are not allowed

#### :-1: Examples of **incorrect** code for this rule with the `"allow"` option:

```coffeescript
###eslint coffee/boolean-keywords: ["error", {"allow": ["yes", "no"]}]###

a is true

someFunction(on)

b = false if c()

off


###eslint coffee/boolean-keywords: ["error", {"allow": ["yes", "no", "on", "off"]}]###

x = true

y or false


###eslint coffee/boolean-keywords: ["error", {"allow": ["true", "false"]}]###

someFunction(on)

off

yes if b

c = no
```

### :+1: Examples of **correct** code for this rule with the `"allow"` option:

```coffeescript
###eslint coffee/boolean-keywords: ["error", {"allow": ["yes", "no", "on", "off"]}]###

a is yes

b = no if c()

someSetting = on

someOtherSetting = off
```

#### :-1: Examples of **incorrect** code for this rule with the `"disallow"` option:

```coffeescript
###eslint coffee/boolean-keywords: ["error", {"disallow": ["yes", "no"]}]###

a is yes

b = no if c()


###eslint coffee/boolean-keywords: ["error", {"disallow": ["true", "false"]}]###

x = true

y or false
```

#### :+1: Examples of **correct** code for this rule with the `"disallow"` option:

```coffeescript
###eslint coffee/boolean-keywords: ["error", {"disallow": ["yes", "no"]}]###

a is true

y or false

someSetting = on

someOtherSetting = off
```
