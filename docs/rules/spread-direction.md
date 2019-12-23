# coffee/spread-direction

This rule enforces consistent use of prefix vs postfix `...`

### Options

This rule has a string option:
```
"coffee/spread-direction": ["error", "prefix"]
```
- `"prefix"` (default) requires `...` to come before its expression
- `"postfix"` requires `...` to come after its expression

#### :-1: Examples of **incorrect** code for this rule with the default `"prefix"` option:

```coffeescript
###eslint coffee/spread-direction: ["error", "prefix"]###

a = {b..., c}

[b...] = c

(b..., c) ->

<div {b...} />
```

#### :+1: Examples of **correct** code for this rule with the default `"prefix"` option:

```coffeescript
###eslint coffee/spread-direction: ["error", "prefix"]###

a = {...b, c}

[...b] = c

(...b, c) ->

<div {...b} />

[..., b] = c
```

#### :-1: Examples of **incorrect** code for this rule with the `"postfix"` option:

```coffeescript
###eslint coffee/spread-direction: ["error", "postfix"]###

a = {...b, c}

[...b] = c

(...b, c) ->

<div {...b} />
```

#### :+1: Examples of **correct** code for this rule with the `"postfix"` option:

```coffeescript
###eslint coffee/spread-direction: ["error", "postfix"]###

a = {b..., c}

[b...] = c

(b..., c) ->

<div {b...} />

[..., b] = c
```
