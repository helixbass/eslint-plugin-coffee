# eslint-plugin-coffee
ESLint custom parser + rules for linting CoffeeScript source files

## Table of Contents

- [Getting Started](#getting-started)
- [Why does this project exist?](#why-does-this-project-exist)
- [How does eslint-plugin-coffee work?](#how-does-eslint-plugin-coffee-work)
- [Can I use all of the existing ESLint plugins and rules without any changes?](#can-i-use-all-of-the-existing-eslint-plugins-and-rules-without-any-changes)
- [Installation](#installation)
- [Usage](#usage)
- [Usage with Prettier](#usage-with-prettier)
- [Supported Rules](#supported-rules)
  - [ESLint-included rules](#eslint-included-rules)
  - [CoffeeScript-specific rules](#coffeescript-specific-rules)
  - [eslint-plugin-react rules](#eslint-plugin-react-rules)
  - [eslint-plugin-import rules](#eslint-plugin-import-rules)
  - [eslint-plugin-react-native rules](#eslint-plugin-react-native-rules)
  - [eslint-plugin-jsx-a11y rules](#eslint-plugin-jsx-a11y-rules)
- [Supported CoffeeScript version](#supported-coffeescript-version)
- [Supported ESLint version](#supported-eslint-version)
- [Supported versions of eslint-plugin-react, eslint-plugin-import, eslint-plugin-react-native, eslint-plugin-jsx-a11y](#supported-versions-of-eslint-plugin-react-eslint-plugin-import-eslint-plugin-react-native-eslint-plugin-jsx-a11y)
- [Migrating from CoffeeLint](#migrating-from-coffeelint)
- [How can I help?](#how-can-i-help)
- [License](#license)

## Getting Started

The following sections will give you an overview of what this project is, why it exists and how it works.

If you are ready to get started you can jump to [Installation](#installation).

## Why does this project exist?

ESLint is the preeminent linter in the JavaScript world.

As of [CoffeeScript v2.5.0](http://coffeescript.org/), the CoffeeScript compiler exposes an Abstract Syntax Tree (AST) representation
of your source code which enables usage with AST-based tools like ESLint.

`eslint-plugin-coffee` is the package that allows you to use ESLint in CoffeeScript-based projects :sparkles: :rainbow: :sparkles:

## How does `eslint-plugin-coffee` work?

The AST (see above) produced by CoffeeScript is different than the AST format that ESLint requires to work.

This means that by default, the CoffeeScript AST is not compatible with the 1000s of rules which have been written
by and for ESLint users over the many years the project has been going.

The great thing is, though, we can provide ESLint with an alternative parser to use - that is a first-class use case
offered by ESLint. `eslint-plugin-coffee` provides ESLint with that alternative parser for CoffeeScript.

At that point, ESLint is capable of "digesting" CoffeeScript source code. But what about the rules? Keep reading...

## Can I use all of the existing ESLint plugins and rules without any changes?

The short answer is, no.

The great news is, **there are many rules which will "just work"** without you having to change anything about them
or provide any custom alternatives.

For rules which don't "just work" for CoffeeScript, `eslint-plugin-coffee` aims to provide a CoffeeScript-compatible
custom alternative rule - this includes rules that come with ESLint, as well as from the popular ESLint plugins
[`eslint-plugin-react`](https://github.com/yannickcr/eslint-plugin-react), [`eslint-plugin-import`](https://github.com/benmosher/eslint-plugin-import),
[`eslint-plugin-react-native`](https://github.com/intellicode/eslint-plugin-react-native), and [`eslint-plugin-jsx-a11y`](https://github.com/evcohen/eslint-plugin-jsx-a11y).

**Here's a [guide to all of the supported rules](#supported-rules).**

## Installation

Make sure you have supported versions of CoffeeScript and ESLint installed and install the plugin:

yarn:
```
# yarn seems to occasionally get confused by Github dependencies, so I'd recommend clearing your lockfile first
rm yarn.lock
# then explicitly install the dependencies and plugin
yarn add --dev github:jashkenas/coffeescript#05d45e9b eslint@^6.0.0 eslint-plugin-coffee
```

npm:

```
# npm also seems to occasionally get confused by Github dependencies, so I'd recommend clearing your lockfile first
rm package-lock.json
# then explicitly install the dependencies
npm install --save-dev github:jashkenas/coffeescript#05d45e9b eslint@^6.0.0 eslint-plugin-coffee
```

## Usage

Add `eslint-plugin-coffee` to the `parser` field and `coffee` to the plugins section of your `.eslintrc` configuration file:

```
{
  "parser": "eslint-plugin-coffee",
  "plugins": ["coffee"]
}
```

Then configure the rules you want to use under the rules section.
```
{
  "parser": "eslint-plugin-coffee",
  "plugins": ["coffee"],
  "rules": {
    // Can include existing rules that "just work":
    "no-undef": "error",
    "react/no-array-index-key": "error",
    // ...CoffeeScript-specific rules:
    "coffee/spread-direction": ["error", "postfix"],
    // ...and CoffeeScript custom overriding rules.
    // For these, the corresponding existing rule should also be disabled if need be:
    "no-unused-vars": "off",
    "coffee/no-unused-vars": "error"
}
```

To apply [eslint:recommended](https://eslint.org/docs/rules/) (the set of rules which are recommended for all
projects by the ESLint team) with this plugin, add `plugin:coffee/eslint-recommended` (which will adjust the `eslint:recommended` config appropriately for CoffeeScript) to your config:

```
{
  "extends": [
    "plugin:coffee/eslint-recommended"
  ]
}
```

#### eslint-plugin-import

If you want to use rules from `eslint-plugin-import` (whether rules that "just work" or CoffeeScript custom overrides),
add `plugin:coffee/import` (which configures `eslint-plugin-import` to work with CoffeeScript) to your config, along with the rules you want to use:
```
{
  "extends": [
    "plugin:coffee/import"
  ],
  "rules": {
    // Can include existing rules that "just work":
    "import/no-unresolved": "error",
    // ...and CoffeeScript custom overriding rules.
    // For these, the corresponding existing rule should also be disabled if need be:
    "import/no-anonymous-default-export": "off",
    "coffee/no-anonymous-default-export": "error",
  }
}
```

See [below](#eslint-plugin-import-rules) for a list of all supported rules from `eslint-plugin-import`.

#### eslint-plugin-react, eslint-plugin-react-native, eslint-plugin-jsx-a11y

If you want to use rules from `eslint-plugin-react`, `eslint-plugin-react-native` and/or `eslint-plugin-jsx-a11y`
(whether rules that "just work" or CoffeeScript custom overrides), add those plugins and rules to your config:
```
{
  "plugins": [
    "coffee",
    "react",
    "react-native",
    "jsx-a11y"
  ],
  "rules": {
    // Can include existing rules that "just work":
    "react/no-array-index-key": "error",
    "react-native/no-inline-styles": "error",
    "jsx-a11y/accessible-emoji": "error",
    // ...and CoffeeScript custom overriding rules.
    // For these, the corresponding existing rule should also be disabled if need be:
    "react/prop-types": "off",
    "coffee/prop-types": "error",
    "react-native/no-unused-styles": "off",
    "coffee/no-unused-styles": "error",
  }
} 
```

To apply the [`recommended`](https://github.com/yannickcr/eslint-plugin-react#recommended) config from `eslint-plugin-react`,
add `plugin:coffee/react-recommended` to your config:

```
{
  "extends": [
    "plugin:coffee/react-recommended"
  ]
}
```

To apply the [`all`](https://github.com/yannickcr/eslint-plugin-react#all) config from `eslint-plugin-react`,
add `plugin:coffee/react-all` to your config:

```
{
  "extends": [
    "plugin:coffee/react-all"
  ]
}
```

To apply the [`recommended`](https://github.com/evcohen/eslint-plugin-jsx-a11y#usage) config from `eslint-plugin-jsx-a11y`,
add `plugin:jsx-a11y/recommended` to your config:

```
{
  "plugins: [
    "coffee",
    "jsx-a11y"
  ],
  "extends": [
    "plugin:jsx-a11y/recommended"
  ]
}
```

To apply the [`strict`](https://github.com/evcohen/eslint-plugin-jsx-a11y#usage) config from `eslint-plugin-jsx-a11y`,
add `plugin:jsx-a11y/strict` to your config:

```
{
  "plugins: [
    "coffee",
    "jsx-a11y"
  ],
  "extends": [
    "plugin:jsx-a11y/strict"
  ]
}
```

See below for a list of all supported rules from [`eslint-plugin-react`](#eslint-plugin-react-rules), [`eslint-plugin-react-native`](#eslint-plugin-react-native-rules) and [`eslint-plugin-jsx-a11y`](#eslint-plugin-jsx-a11y-rules).

### Running from the command line

To invoke ESLint from the command line, you can add an appropriate script to your `package.json` scripts section, for example:

```
{
  "scripts": {
    "lint": "eslint 'src/**/*.coffee'",
    "lint-fix": "eslint --fix 'src/**/*.coffee'"
  }
}
```

Then you can invoke those scripts as needed from the command line to lint the CoffeeScript source files in your project:
```
npm run lint
```

### Running from your editor

Running ESLint directly from your code editor (e.g. on save) provides a quick feedback loop while developing.

Depending on your editor, there may or may not currently be a straightforward way to get ESLint running against `.coffee` files (e.g. using an ESLint editor plugin).

If you're having trouble getting ESLint running in your editor (and it's not listed below), please [file an issue](https://github.com/helixbass/eslint-plugin-coffee/issues) and we'll try and help with support for your editor.

#### VS Code

To run ESLint from VS Code, first install the VS Code [ESLint extension](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint).

Then add to your VS Code [`settings.json`](https://code.visualstudio.com/docs/getstarted/settings):
```
"eslint.validate": [
    // "javascript", "javascriptreact" is the default setting
    "javascript",
    "javascriptreact",
    {
        "language": "coffeescript",
        "autoFix": true
    },
]
```

#### Other editors

We will add instructions for different code editors here as they become supported.

If you've gotten ESLint running in an editor not listed here and would like to share back, please [file an issue](https://github.com/helixbass/eslint-plugin-coffee/issues)!

## Usage with Prettier

You can now use [Prettier](https://prettier.io/) to format your CoffeeScript code, see the Prettier CoffeeScript plugin [README](https://github.com/helixbass/prettier-plugin-coffeescript) for instructions.

To disable our code formatting related rules, install [`eslint-config-prettier`](https://github.com/prettier/eslint-config-prettier):

```
npm install --save-dev eslint-config-prettier
```

Then use the `prettier` config exposed by this plugin:
```
{
  "extends": ["plugin:coffee/prettier"]
}
```

Alternatively, if you want to run Prettier as an ESLint rule (a nice option especially if you're running ESLint in fix mode
via your editor):

```
npm install --save-dev eslint-config-prettier eslint-plugin-prettier
```

Then use the `prettier-run-as-rule` config exposed by this plugin:
```
{
  "extends": ["plugin:coffee/prettier-run-as-rule"]
}
```

## Supported Rules

**Key**: :heavy_check_mark: = ESLint recommended, :wrench: = fixable

### ESLint-included rules

#### Possible Errors

|                    |          | Name                                    | Description |
| ------------------ | -------- | --------------------------------------- | ----------- |
| :heavy_check_mark: |          | [`coffee/no-async-promise-executor`](https://eslint.org/docs/rules/no-async-promise-executor)   | disallow using an async function as a Promise executor |
|                    |          | [`coffee/no-await-in-loop`](https://eslint.org/docs/rules/no-await-in-loop) | disallow `await` inside of loops |
| :heavy_check_mark: |          | [`coffee/no-compare-neg-zero`](https://eslint.org/docs/rules/no-compare-neg-zero) | disallow comparing against -0 |
| :heavy_check_mark: |          | [`coffee/no-cond-assign`](https://eslint.org/docs/rules/no-cond-assign) | disallow assignment operators in conditional expressions |
|                    |          | [`no-console`](https://eslint.org/docs/rules/no-console) | disallow the use of `console` |
| :heavy_check_mark: |          | [`coffee/no-constant-condition`](https://eslint.org/docs/rules/no-constant-condition) | disallow constant expressions in conditions |
| :heavy_check_mark: |          | [`no-control-regex`](https://eslint.org/docs/rules/no-control-regex) | disallow control characters in regular expressions |
| :heavy_check_mark: |          | [`no-debugger`](https://eslint.org/docs/rules/no-debugger) | disallow the use of `debugger` |
| :heavy_check_mark: |          | [`no-dupe-keys`](https://eslint.org/docs/rules/no-dupe-keys) | disallow duplicate keys in object literals |
| :heavy_check_mark: |          | [`no-duplicate-case`](https://eslint.org/docs/rules/no-duplicate-case) | disallow duplicate case labels |
| :heavy_check_mark: |          | [`no-empty`](https://eslint.org/docs/rules/no-empty) | disallow empty block statements |
| :heavy_check_mark: |          | [`coffee/no-empty-character-class`](https://eslint.org/docs/rules/no-empty-character-class) | disallow empty character classes in regular expressions |
| :heavy_check_mark: |          | [`no-ex-assign`](https://eslint.org/docs/rules/no-ex-assign) | disallow reassigning exceptions in `catch` clauses |
| :heavy_check_mark: |          | [`coffee/no-extra-boolean-cast`](https://eslint.org/docs/rules/no-extra-boolean-cast) | disallow unnecessary boolean casts <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
| :heavy_check_mark: |          | [`coffee/no-inner-declarations`](https://eslint.org/docs/rules/no-inner-declarations) | disallow variable or `function` "declarations" in nested blocks |
| :heavy_check_mark: |          | [`no-invalid-regexp`](https://eslint.org/docs/rules/no-invalid-regexp) | disallow invalid regular expression strings in `RegExp` constructors |
| :heavy_check_mark: |          | [`no-irregular-whitespace`](https://eslint.org/docs/rules/no-irregular-whitespace) | disallow irregular whitespace |
| :heavy_check_mark: |          | [`no-misleading-character-class`](https://eslint.org/docs/rules/no-misleading-character-class) | disallow characters which are made with multiple code points in character class syntax |
| :heavy_check_mark: |          | [`no-obj-calls`](https://eslint.org/docs/rules/no-obj-calls) | disallow calling global object properties as functions |
| :heavy_check_mark: |          | [`no-prototype-builtins`](https://eslint.org/docs/rules/no-prototype-builtins) | disallow calling some `Object.prototype` methods directly on objects |
| :heavy_check_mark: | :wrench: | [`coffee/no-regex-spaces`](https://eslint.org/docs/rules/no-regex-spaces) | disallow multiple spaces in regular expressions |
| :heavy_check_mark: |          | [`no-sparse-arrays`](https://eslint.org/docs/rules/no-sparse-arrays) | disallow sparse arrays |
|                    |          | [`coffee/no-template-curly-in-string`](https://eslint.org/docs/rules/no-template-curly-in-string) | disallow template literal placeholder syntax in regular strings |
| :heavy_check_mark: |          | [`coffee/no-unreachable`](https://eslint.org/docs/rules/no-unreachable) | disallow unreachable code after `return`, `throw`, `continue`, and `break` statements |
| :heavy_check_mark: |          | [`no-unsafe-finally`](https://eslint.org/docs/rules/no-unsafe-finally) | disallow control flow statements in `finally` blocks |
| :heavy_check_mark: |          | [`coffee/no-unsafe-negation`](https://eslint.org/docs/rules/no-unsafe-negation) | disallow negating the left operand of relational operators |
| :heavy_check_mark: |          | [`require-atomic-updates`](https://eslint.org/docs/rules/require-atomic-updates) | disallow assignments that can lead to race conditions due to usage of `await` or `yield` |
| :heavy_check_mark: |          | [`coffee/use-isnan`](https://eslint.org/docs/rules/use-isnan) | require calls to `isNaN()` when checking for `NaN` |
| :heavy_check_mark: |          | [`coffee/valid-typeof`](https://eslint.org/docs/rules/valid-typeof) | enforce comparing `typeof` expressions against valid strings |

#### Best Practices

|                    |          | Name                                    | Description |
| ------------------ | -------- | --------------------------------------- | ----------- |
|                    |          | [`accessor-pairs`](https://eslint.org/docs/rules/accessor-pairs) | enforce getter and setter pairs in objects and classes <br> :warning: Only checks e.g. `Object.defineProperty()` since CoffeeScript doesn't support getters/setters |
|                    |          | [`coffee/block-scoped-var`](https://eslint.org/docs/rules/block-scoped-var) | enforce the use of variables within the scope they are defined |
|                    |          | [`coffee/class-methods-use-this`](https://eslint.org/docs/rules/class-methods-use-this) | enforce that class methods utilize `this` |
|                    |          | [`coffee/complexity`](https://eslint.org/docs/rules/complexity) | enforce a maximum cyclomatic complexity allowed in a program |
|                    |          | [`default-case`](https://eslint.org/docs/rules/default-case) | require `else` cases in `switch` statements |
|                    | :wrench: | [`coffee/dot-location`](https://eslint.org/docs/rules/dot-location) | enforce consistent newlines before and after dots |
|                    | :wrench: | [`coffee/dot-notation`](https://eslint.org/docs/rules/dot-notation) | enforce dot notation whenever possible |
|                    |          | [`coffee/guard-for-in`](https://eslint.org/docs/rules/guard-for-in) | require `for-of` loops to include `own` or an `if` statement |
|                    |          | [`max-classes-per-file`](https://eslint.org/docs/rules/max-classes-per-file) | enforce a maximum number of classes per file |
|                    |          | [`no-alert`](https://eslint.org/docs/rules/no-alert) | disallow the use of `alert`, `confirm`, and `prompt` |
|                    |          | [`no-caller`](https://eslint.org/docs/rules/no-caller) | disallow the use of `arguments.caller` or `arguments.callee` |
|                    | :wrench: | [`coffee/no-div-regex`](https://eslint.org/docs/rules/no-div-regex) | disallow division operators explicitly at the beginning of regular expressions |
|                    |          | [`coffee/no-else-return`](https://eslint.org/docs/rules/no-else-return) | disallow `else` blocks after `return` statements in `if` statements <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    |          | [`coffee/no-empty-function`](https://eslint.org/docs/rules/no-empty-function) | disallow empty functions |
| :heavy_check_mark: |          | [`no-empty-pattern`](https://eslint.org/docs/rules/no-empty-pattern) | disallow empty destructuring patterns |
|                    |          | [`no-eval`](https://eslint.org/docs/rules/no-eval) | disallow the use of `eval()` |
|                    |          | [`no-extend-native`](https://eslint.org/docs/rules/no-extend-native) | disallow extending native types |
|                    | :wrench: | [`coffee/no-extra-bind`](https://eslint.org/docs/rules/no-extra-bind) | disallow unnecessary calls to `.bind()` |
|                    | :wrench: | [`no-floating-decimal`](https://eslint.org/docs/rules/no-floating-decimal) | disallow leading or trailing decimal points in numeric literals |
| :heavy_check_mark: |          | [`no-global-assign`](https://eslint.org/docs/rules/no-global-assign) | disallow assignments to native objects or read-only global variables <br> :warning: Only applies to e.g. `++` operations since CoffeeScript generates declarations on other write references. |
|                    | :wrench: | [`coffee/no-implicit-coercion`](https://eslint.org/docs/rules/no-implicit-coercion) | disallow shorthand type conversions |
|                    |          | [`no-implied-eval`](https://eslint.org/docs/rules/no-implied-eval) | disallow the use of `eval()`-like methods |
|                    |          | [`coffee/no-invalid-this`](https://eslint.org/docs/rules/no-invalid-this) | disallow `this` keywords outside of classes or class-like objects |
|                    |          | [`no-iterator`](https://eslint.org/docs/rules/no-iterator) | disallow the use of the `__iterator__` property |
|                    |          | [`coffee/no-loop-func`](https://eslint.org/docs/rules/no-loop-func) | disallow function declarations that contain unsafe references inside loop statements |
|                    |          | [`coffee/no-magic-numbers`](https://eslint.org/docs/rules/no-magic-numbers) | disallow magic numbers |
|                    | :wrench: | [`coffee/no-multi-spaces`](https://eslint.org/docs/rules/no-multi-spaces) | disallow multiple spaces |
|                    |          | [`coffee/no-new`](https://eslint.org/docs/rules/no-new) | disallow `new` operators outside of assignments or comparisons |
|                    |          | [`no-new-func`](https://eslint.org/docs/rules/no-new-func) | disallow `new` operators with the `Function` object |
|                    |          | [`no-new-wrappers`](https://eslint.org/docs/rules/no-new-wrappers) | disallow `new` operators with the `String`, `Number`, and `Boolean` objects |
|                    |          | [`no-param-reassign`](https://eslint.org/docs/rules/no-param-reassign) | disallow reassigning `function` parameters |
|                    |          | [`no-proto`](https://eslint.org/docs/rules/no-proto) | disallow the use of the `__proto__` property |
|                    |          | [`no-restricted-properties`](https://eslint.org/docs/rules/no-restricted-properties) | disallow certain properties on certain objects |
|                    |          | [`coffee/no-return-assign`](https://eslint.org/docs/rules/no-return-assign) | disallow assignment operators in `return` statements <br> :warning: Currently, this also flags assignments in implicit return statements |
|                    |          | [`no-script-url`](https://eslint.org/docs/rules/no-script-url) | disallow `javascript:` urls |
| :heavy_check_mark: |          | [`coffee/no-self-assign`](https://eslint.org/docs/rules/no-self-assign) | disallow assignments where both sides are exactly the same |
|                    |          | [`coffee/no-self-compare`](https://eslint.org/docs/rules/no-self-compare) | disallow comparisons where both sides are exactly the same |
|                    |          | [`coffee/no-sequences`](https://eslint.org/docs/rules/no-sequences) | disallow semicolon operators |
|                    |          | [`no-throw-literal`](https://eslint.org/docs/rules/no-throw-literal) | disallow throwing literals as exceptions |
|                    |          | [`coffee/no-unmodified-loop-condition`](https://eslint.org/docs/rules/no-unmodified-loop-condition) | disallow unmodified loop conditions |
|                    |          | [`coffee/no-unused-expressions`](https://eslint.org/docs/rules/no-unused-expressions) | disallow unused expressions |
|                    |          | [`no-useless-call`](https://eslint.org/docs/rules/no-useless-call) | disallow unnecessary calls to `.call()` and `.apply()` |
| :heavy_check_mark: |          | [`no-useless-catch`](https://eslint.org/docs/rules/no-useless-catch) | disallow unnecessary `catch` clauses |
|                    |          | [`no-useless-concat`](https://eslint.org/docs/rules/no-useless-concat) | disallow unnecessary concatenation of literals or template literals |
| :heavy_check_mark: |          | [`coffee/no-useless-escape`](https://eslint.org/docs/rules/no-useless-escape) | disallow unnecessary escape characters |
|                    | :wrench: | [`coffee/no-useless-return`](https://eslint.org/docs/rules/no-useless-return) | disallow redundant return statements |
|                    |          | [`no-warning-comments`](https://eslint.org/docs/rules/no-warning-comments) | disallow specified warning terms in comments |
|                    |          | [`prefer-promise-reject-errors`](https://eslint.org/docs/rules/prefer-promise-reject-errors) | require using Error objects as Promise rejection reasons |
|                    |          | [`radix`](https://eslint.org/docs/rules/radix) | enforce the consistent use of the radix argument when using `parseInt()` |
|                    |          | [`require-unicode-regexp`](https://eslint.org/docs/rules/require-unicode-regexp) | enforce the use of `u` flag on RegExp |
|                    |          | [`coffee/vars-on-top`](https://eslint.org/docs/rules/vars-on-top) | require "declarations" be placed at the top of their containing scope |
|                    |          | [`coffee/yoda`](https://eslint.org/docs/rules/yoda) | require or disallow "Yoda" conditions <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
| :heavy_check_mark: |          | [`no-delete-var`](https://eslint.org/docs/rules/no-delete-var) | disallow deleting variables |
|                    |          | [`no-restricted-globals`](https://eslint.org/docs/rules/no-restricted-globals) | disallow specified global variables |
|                    |          | [`coffee/no-shadow`](https://eslint.org/docs/rules/no-shadow) | disallow variable declarations from shadowing variables declared in the outer scope |
| :heavy_check_mark: |          | [`no-undef`](https://eslint.org/docs/rules/no-undef) | disallow the use of undeclared variables unless mentioned in `###global ###` comments |
| :heavy_check_mark: |          | [`coffee/no-unused-vars`](https://eslint.org/docs/rules/no-unused-vars) | disallow unused variables |
|                    |          | [`coffee/no-use-before-define`](https://eslint.org/docs/rules/no-use-before-define) | disallow the use of variables before they are "defined" |

#### Node.js and CommonJS

|                    |          | Name                                    | Description |
| ------------------ | -------- | --------------------------------------- | ----------- |
|                    |          | [`coffee/callback-return`](https://eslint.org/docs/rules/callback-return) | require `return` statements after callbacks |
|                    |          | [`global-require`](https://eslint.org/docs/rules/global-require) | require `require()` calls to be placed at top-level module scope |
|                    |          | [`handle-callback-err`](https://eslint.org/docs/rules/handle-callback-err) | require error handling in callbacks |
|                    |          | [`no-buffer-constructor`](https://eslint.org/docs/rules/no-buffer-constructor) | disallow use of the `Buffer()` constructor |
|                    |          | [`no-new-require`](https://eslint.org/docs/rules/no-new-require) | disallow `new` operators with calls to `require` |
|                    |          | [`no-path-concat`](https://eslint.org/docs/rules/no-path-concat) | disallow string concatenation with `__dirname` and `__filename` |
|                    |          | [`no-process-env`](https://eslint.org/docs/rules/no-process-env) | disallow the use of `process.env` |
|                    |          | [`no-process-exit`](https://eslint.org/docs/rules/no-process-exit) | disallow the use of `process.exit()` |
|                    |          | [`no-restricted-modules`](https://eslint.org/docs/rules/no-restricted-modules) | disallow specified modules when loaded by `require` |
|                    |          | [`no-sync`](https://eslint.org/docs/rules/no-sync) | disallow synchronous methods |

#### Stylistic Issues

|                    |          | Name                                    | Description |
| ------------------ | -------- | --------------------------------------- | ----------- |
|                    |          | [`coffee/array-bracket-newline`](https://eslint.org/docs/rules/array-bracket-newline) | enforce linebreaks after opening and before closing array brackets <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    | :wrench: | [`coffee/array-bracket-spacing`](https://eslint.org/docs/rules/array-bracket-spacing) | enforce consistent spacing inside array brackets |
|                    |          | [`coffee/array-element-newline`](https://eslint.org/docs/rules/array-element-newline) | enforce line breaks after each array element <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    |          | [`coffee/camelcase`](https://eslint.org/docs/rules/camelcase) | enforce camelcase naming convention |
|                    | :wrench: | [`coffee/capitalized-comments`](https://eslint.org/docs/rules/capitalized-comments) | enforce or disallow capitalization of the first letter of a comment |
|                    | :wrench: | [`comma-spacing`](https://eslint.org/docs/rules/comma-spacing) | enforce consistent spacing before and after commas |
|                    |          | [`coffee/comma-style`](https://eslint.org/docs/rules/comma-style) | enforce consistent comma style <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    | :wrench: | [`computed-property-spacing`](https://eslint.org/docs/rules/computed-property-spacing) | enforce consistent spacing inside computed property brackets |
|                    |          | [`coffee/consistent-this`](https://eslint.org/docs/rules/consistent-this) | enforce consistent naming when capturing the current execution context |
|                    | :wrench: | [`eol-last`](https://eslint.org/docs/rules/eol-last) | require or disallow newline at the end of files |
|                    |          | [`coffee/function-paren-newline`](https://eslint.org/docs/rules/function-paren-newline) | enforce consistent line breaks inside function parentheses <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    |          | [`id-blacklist`](https://eslint.org/docs/rules/id-blacklist) | disallow specified identifiers |
|                    |          | [`coffee/id-length`](https://eslint.org/docs/rules/id-length) | enforce minimum and maximum identifier lengths |
|                    |          | [`coffee/id-match`](https://eslint.org/docs/rules/id-match) | require identifiers to match a specified regular expression |
|                    |          | [`coffee/implicit-arrow-linebreak`](https://eslint.org/docs/rules/implicit-arrow-linebreak) | enforce the location of function bodies <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    | :wrench: | [`jsx-quotes`](https://eslint.org/docs/rules/jsx-quotes) | enforce the consistent use of either double or single quotes in JSX attributes |
|                    | :wrench: | [`key-spacing`](https://eslint.org/docs/rules/key-spacing) | enforce consistent spacing between keys and values in object literal properties |
|                    | :wrench: | [`coffee/keyword-spacing`](https://eslint.org/docs/rules/keyword-spacing) | enforce consistent spacing before and after keywords |
|                    |          | [`line-comment-position`](https://eslint.org/docs/rules/line-comment-position) | enforce position of line comments |
|                    | :wrench: | [`linebreak-style`](https://eslint.org/docs/rules/linebreak-style) | enforce consistent linebreak style |
|                    | :wrench: | [`coffee/lines-around-comment`](https://eslint.org/docs/rules/lines-around-comment) | require empty lines around comments |
|                    |          | [`coffee/lines-between-class-members`](https://eslint.org/docs/rules/lines-between-class-members) | require or disallow an empty line between class members <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    |          | [`coffee/max-depth`](https://eslint.org/docs/rules/max-depth) | enforce a maximum depth that blocks can be nested |
|                    |          | [`coffee/max-len`](https://eslint.org/docs/rules/max-len) | enforce a maximum line length |
|                    |          | [`max-lines`](https://eslint.org/docs/rules/max-lines) | enforce a maximum number of lines per file |
|                    |          | [`coffee/max-lines-per-function`](https://eslint.org/docs/rules/max-lines-per-function) | enforce a maximum number of line of code in a function |
|                    |          | [`max-nested-callbacks`](https://eslint.org/docs/rules/max-nested-callbacks) | enforce a maximum depth that callbacks can be nested |
|                    |          | [`max-params`](https://eslint.org/docs/rules/max-params) | enforce a maximum number of parameters in function definitions |
|                    |          | [`max-statements`](https://eslint.org/docs/rules/max-statements) | enforce a maximum number of statements allowed in function blocks |
|                    | :wrench: | [`coffee/multiline-comment-style`](https://eslint.org/docs/rules/multiline-comment-style) | enforce a particular style for multiline comments |
|                    |          | [`new-cap`](https://eslint.org/docs/rules/new-cap) | require constructor names to begin with a capital letter |
|                    | :wrench: | [`new-parens`](https://eslint.org/docs/rules/new-parens) | enforce or disallow parentheses when invoking a constructor with no arguments |
|                    |          | [`coffee/newline-per-chained-call`](https://eslint.org/docs/rules/newline-per-chained-call) | require a newline after each call in a method chain <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    |          | [`no-array-constructor`](https://eslint.org/docs/rules/no-array-constructor) | disallow `Array` constructors |
|                    |          | [`no-bitwise`](https://eslint.org/docs/rules/no-bitwise) | disallow bitwise operators |
|                    |          | [`no-continue`](https://eslint.org/docs/rules/no-continue) | disallow `continue` statements |
|                    |          | [`no-inline-comments`](https://eslint.org/docs/rules/no-inline-comments) | disallow inline comments after code |
|                    |          | [`coffee/no-lonely-if`](https://eslint.org/docs/rules/no-lonely-if) | disallow `if` statements as the only statement in `else` blocks <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    |          | [`coffee/no-mixed-operators`](https://eslint.org/docs/rules/no-mixed-operators) | disallow mixed binary operators |
|                    |          | [`no-multi-assign`](https://eslint.org/docs/rules/no-multi-assign) | disallow use of chained assignment expressions |
|                    | :wrench: | [`coffee/no-multiple-empty-lines`](https://eslint.org/docs/rules/no-multiple-empty-lines) | disallow multiple empty lines |
|                    |          | [`coffee/no-negated-condition`](https://eslint.org/docs/rules/no-negated-condition) | disallow negated conditions |
|                    |          | [`no-new-object`](https://eslint.org/docs/rules/no-new-object) | disallow `Object` constructors |
|                    |          | [`no-plusplus`](https://eslint.org/docs/rules/no-plusplus) | disallow the unary operators `++` and `--` |
|                    |          | [`no-restricted-syntax`](https://eslint.org/docs/rules/no-restricted-syntax) | disallow specified syntax |
|                    |          | [`no-tabs`](https://eslint.org/docs/rules/no-tabs) | disallow all tabs |
|                    | :wrench: | [`no-trailing-spaces`](https://eslint.org/docs/rules/no-trailing-spaces) | disallow trailing whitespace at the end of lines |
|                    |          | [`coffee/no-underscore-dangle`](https://eslint.org/docs/rules/no-underscore-dangle) | disallow dangling underscores in identifiers |
|                    | :wrench: | [`coffee/no-unneeded-ternary`](https://eslint.org/docs/rules/no-unneeded-ternary) | disallow `if`/`else` expressions when simpler alternatives exist |
|                    | :wrench: | [`coffee/no-whitespace-before-property`](https://eslint.org/docs/rules/no-whitespace-before-property) | disallow whitespace before properties |
|                    | :wrench: | [`coffee/object-curly-spacing`](https://eslint.org/docs/rules/object-curly-spacing) | enforce consistent spacing inside braces |
|                    |          | [`coffee/object-property-newline`](https://eslint.org/docs/rules/object-property-newline) | enforce placing object properties on separate lines <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    | :wrench: | [`coffee/operator-assignment`](https://eslint.org/docs/rules/operator-assignment) | require or disallow assignment operator shorthand where possible |
|                    |          | [`coffee/operator-linebreak`](https://eslint.org/docs/rules/operator-linebreak) | enforce consistent linebreak style for operators <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    |          | [`coffee/prefer-object-spread`](https://eslint.org/docs/rules/prefer-object-spread) | disallow using Object.assign with an object literal as the first argument and prefer the use of object spread instead <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    | :wrench: | [`quote-props`](https://eslint.org/docs/rules/quote-props) | require quotes around object literal property names |
|                    |          | [`sort-keys`](https://eslint.org/docs/rules/sort-keys) | require object keys to be sorted |
|                    | :wrench: | [`space-in-parens`](https://eslint.org/docs/rules/space-in-parens) | enforce consistent spacing inside parentheses |
|                    | :wrench: | [`coffee/space-infix-ops`](https://eslint.org/docs/rules/space-infix-ops) | require spacing around infix operators |
|                    | :wrench: | [`coffee/space-unary-ops`](https://eslint.org/docs/rules/space-unary-ops) | enforce consistent spacing before or after unary operators |
|                    | :wrench: | [`coffee/spaced-comment`](https://eslint.org/docs/rules/spaced-comment) | enforce consistent spacing after the `#` or `###` in a comment |
|                    | :wrench: | [`unicode-bom`](https://eslint.org/docs/rules/unicode-bom) | require or disallow Unicode byte order mark (BOM) |
|                    | :wrench: | [`coffee/wrap-regex`](https://eslint.org/docs/rules/wrap-regex) | require parenthesis around regex literals |

#### "ECMAScript 6"

|                    |          | Name                                    | Description |
| ------------------ | -------- | --------------------------------------- | ----------- |
|                    | :wrench: | [`coffee/arrow-spacing`](https://eslint.org/docs/rules/arrow-spacing) | enforce consistent spacing before and after the arrow in functions |
| :heavy_check_mark: |          | [`constructor-super`](https://eslint.org/docs/rules/constructor-super) | require `super()` calls in constructors |
| :heavy_check_mark: |          | [`coffee/no-class-assign`](https://eslint.org/docs/rules/no-class-assign) | disallow reassigning class members |
| :heavy_check_mark: |          | [`no-dupe-class-members`](https://eslint.org/docs/rules/no-dupe-class-members) | disallow duplicate class members |
|                    |          | [`no-duplicate-imports`](https://eslint.org/docs/rules/no-duplicate-imports) | disallow duplicate module imports |
| :heavy_check_mark: |          | [`no-new-symbol`](https://eslint.org/docs/rules/no-new-symbol) | disallow `new` operators with the `Symbol` object |
|                    |          | [`no-restricted-imports`](https://eslint.org/docs/rules/no-restricted-imports) | disallow specified modules when loaded by `import` |
| :heavy_check_mark: |          | [`coffee/no-this-before-super`](https://eslint.org/docs/rules/no-this-before-super) | disallow `this`/`super` before calling `super()` in constructors |
|                    | :wrench: | [`coffee/no-useless-computed-key`](https://eslint.org/docs/rules/no-useless-computed-key) | disallow unnecessary computed property keys in objects and classes |
|                    |          | [`coffee/no-useless-constructor`](https://eslint.org/docs/rules/no-useless-constructor) | disallow unnecessary constructors |
|                    | :wrench: | [`no-useless-rename`](https://eslint.org/docs/rules/no-useless-rename) | disallow renaming import, export, and destructured assignments to the same name |
|                    |          | [`coffee/object-shorthand`](https://eslint.org/docs/rules/object-shorthand) | require or disallow method and property shorthand syntax for object literals <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    |          | [`coffee/prefer-destructuring`](https://eslint.org/docs/rules/prefer-destructuring) | require destructuring from arrays and/or objects <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    | :wrench: | [`prefer-numeric-literals`](https://eslint.org/docs/rules/prefer-numeric-literals) | disallow `parseInt()` and `Number.parseInt()` in favor of binary, octal, and hexadecimal literals |
|                    |          | [`prefer-rest-params`](https://eslint.org/docs/rules/prefer-rest-params) | require rest parameters instead of `arguments` |
|                    |          | [`prefer-spread`](https://eslint.org/docs/rules/prefer-spread) | require spread operators instead of `.apply()` |
|                    | :wrench: | [`coffee/prefer-template`](https://eslint.org/docs/rules/prefer-template) | require interpolated strings instead of string concatenation |
|                    | :wrench: | [`coffee/rest-spread-spacing`](https://eslint.org/docs/rules/rest-spread-spacing) | enforce spacing between rest and spread operators and their expressions |
|                    | :wrench: | [`sort-imports`](https://eslint.org/docs/rules/sort-imports) | enforce sorted import declarations within modules |
|                    |          | [`symbol-description`](https://eslint.org/docs/rules/symbol-description) | require symbol descriptions |
|                    | :wrench: | [`coffee/template-curly-spacing`](https://eslint.org/docs/rules/template-curly-spacing) | require or disallow spacing around embedded expressions of template strings |

### CoffeeScript-specific rules

|          | Name                                    | Description |
| -------- | --------------------------------------- | ----------- |
|          | [`coffee/capitalized-class-names`](./docs/rules/capitalized-class-names.md) | Enforce capitalization of the first letter of a class name |
|          | [`coffee/no-backticks`](./docs/rules/no-backticks.md) | Disallow use of the backtick operator |
|          | [`coffee/english-operators`](./docs/rules/english-operators.md) | Enforce or disallow use of "English" operators |          | [`coffee/no-unnecessary-fat-arrow`](./docs/rules/no-unnecessary-fat-arrow.md) | Disallow unnecessary use of `=>` |          | [`coffee/no-overwrite`](./docs/rules/no-overwrite.md) | Disallow modifying variables from the same or outer scopes |
|          | [`coffee/implicit-object`](./docs/rules/implicit-object.md) | Disallow implicit objects |
|          | [`coffee/implicit-call`](./docs/rules/implicit-call.md) | Disallow implicit function calls |
|          | [`coffee/empty-func-parens`](./docs/rules/empty-func-parens.md) | Enforce or disallow the use of parentheses for empty parameter lists |
|          | [`coffee/shorthand-this`](./docs/rules/shorthand-this.md) | Enforce or disallow use of `@` vs `this` |
|          | [`coffee/spread-direction`](./docs/rules/spread-direction.md) | Enforce consistent use of prefix vs postfix `...` |
| :wrench: | [`coffee/postfix-comprehension-assign-parens`](./docs/rules/postfix-comprehension-assign-parens.md) | Require parentheses around potentially confusing assignments in postfix comprehensions |
|          | [`coffee/no-nested-interpolation`](./docs/rules/no-nested-interpolation.md) | Disallow nesting interpolations |
|          | [`coffee/no-private-function-fat-arrows`](./docs/rules/no-private-function-fat-arrows.md) | Disallow use of `=>` for "private" functions in class bodies |
|          | [`coffee/no-unnecessary-double-quotes`](./docs/rules/no-unnecessary-double-quotes.md) | Disallow use of double quotes for strings when single quotes would suffice |

### eslint-plugin-react rules

**Key**: :heavy_check_mark: = recommended, :wrench: = fixable

|                    |          | Name                                    | Description |
| ------------------ | -------- | --------------------------------------- | ----------- |
|                    |          | [`coffee/boolean-prop-naming`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/boolean-prop-naming.md) | Enforces consistent naming for boolean props |
|                    |          | [`react/button-has-type`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/button-has-type.md) | Forbid "button" element without an explicit "type" attribute |
|                    |          | [`coffee/default-props-match-prop-types`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/default-props-match-prop-types.md) | Prevent extraneous defaultProps on components |
|                    |          | [`coffee/destructuring-assignment`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/destructuring-assignment.md) | Rule enforces consistent usage of destructuring assignment in component |
| :heavy_check_mark: |          | [`coffee/display-name`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/display-name.md) | Prevent missing `displayName` in a React component definition |
|                    |          | [`react/forbid-component-props`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/forbid-component-props.md) | Forbid certain props on Components |
|                    |          | [`react/forbid-dom-props`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/forbid-dom-props.md) | Forbid certain props on DOM Nodes |
|                    |          | [`react/forbid-elements`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/forbid-elements.md) | Forbid certain elements |
|                    |          | [`coffee/forbid-prop-types`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/forbid-prop-types.md) | Forbid certain propTypes |
|                    |          | [`react/forbid-foreign-prop-types`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/forbid-foreign-prop-types.md) | Forbid foreign propTypes |
|                    |          | [`coffee/no-access-state-in-setstate`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-access-state-in-setstate.md) | Prevent using this.state inside this.setState |
|                    |          | [`react/no-array-index-key`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-array-index-key.md) | Prevent using Array index in `key` props |
| :heavy_check_mark: |          | [`react/no-children-prop`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-children-prop.md) | Prevent passing children as props |
|                    |          | [`react/no-danger`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-danger.md) | Prevent usage of dangerous JSX properties |
| :heavy_check_mark: |          | [`coffee/no-danger-with-children`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-danger-with-children.md) | Prevent problem with children and props.dangerouslySetInnerHTML |
| :heavy_check_mark: |          | [`coffee/no-deprecated`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-deprecated.md) | Prevent usage of deprecated methods, including component lifecycle methods |
|                    |          | [`react/no-did-mount-set-state`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-did-mount-set-state.md) | Prevent usage of `setState` in `componentDidMount` |
|                    |          | [`react/no-did-update-set-state`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-did-update-set-state.md) | Prevent usage of `setState` in `componentDidUpdate` |
| :heavy_check_mark: |          | [`react/no-direct-mutation-state`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-direct-mutation-state.md) | Prevent direct mutation of `this.state` |
| :heavy_check_mark: |          | [`react/no-find-dom-node`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-find-dom-node.md) | Prevent usage of `findDOMNode` |
| :heavy_check_mark: |          | [`react/no-is-mounted`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-is-mounted.md) | Prevent usage of `isMounted` |
|                    |          | [`coffee/no-multi-comp`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-multi-comp.md) | Prevent multiple component definition per file |
|                    |          | [`coffee/no-redundant-should-component-update`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-redundant-should-component-update.md) | Prevent usage of `shouldComponentUpdate` when extending React.PureComponent |
| :heavy_check_mark: |          | [`coffee/no-render-return-value`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-render-return-value.md) | Prevent usage of the return value of `React.render` |
|                    |          | [`react/no-set-state`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-set-state.md) | Prevent usage of `setState` |
|                    |          | [`coffee/no-typos`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-typos.md) | Prevent common casing typos |
| :heavy_check_mark: |          | [`react/no-string-refs`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-string-refs.md) | Prevent using string references in `ref` attribute. |
|                    |          | [`coffee/no-this-in-sfc`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-this-in-sfc.md) | Prevent using `this` in stateless functional components |
| :heavy_check_mark: |          | [`coffee/no-unescaped-entities`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-unescaped-entities.md) | Prevent invalid characters from appearing in markup |
| :heavy_check_mark: | :wrench: | [`react/no-unknown-property`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-unknown-property.md) | Prevent usage of unknown DOM property |
|                    |          | [`react/no-unsafe`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-unsafe.md) | Prevent usage of unsafe lifecycle methods |
|                    |          | [`coffee/no-unused-prop-types`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-unused-prop-types.md) | Prevent definitions of unused prop types |
|                    |          | [`coffee/no-unused-state`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-unused-state.md) | Prevent definitions of unused state properties |
|                    |          | [`react/no-will-update-set-state`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/no-will-update-set-state.md) | Prevent usage of `setState` in `componentWillUpdate` |
|                    |          | [`react/prefer-es6-class`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/prefer-es6-class.md) | Enforce ES5 or ES6 class for React Components |
|                    |          | [`coffee/prefer-stateless-function`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/prefer-stateless-function.md) | Enforce stateless React Components to be written as a pure function |
| :heavy_check_mark: |          | [`coffee/prop-types`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/prop-types.md) | Prevent missing props validation in a React component definition |
| :heavy_check_mark: |          | [`react/react-in-jsx-scope`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/react-in-jsx-scope.md) | Prevent missing `React` when using JSX |
|                    |          | [`coffee/require-default-props`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/require-default-props.md) | Enforce a defaultProps definition for every prop that is not a required prop |
|                    |          | [`react/require-optimization`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/require-optimization.md) | Enforce React components to have a `shouldComponentUpdate` method |
|                    | :wrench: | [`react/self-closing-comp`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/self-closing-comp.md) | Prevent extra closing tags for components without children |
|                    |          | [`coffee/sort-comp`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/sort-comp.md) | Enforce component methods order <br> :warning: Unlike the eslint-plugin-react rule, the CoffeeScript version is not fixable |
|                    |          | [`coffee/sort-prop-types`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/sort-prop-types.md) | Enforce propTypes declarations alphabetical sorting |
|                    |          | [`react/static-property-placement`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/static-property-placement.md) | Enforces where React component static properties should be positioned |
|                    |          | [`coffee/style-prop-object`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/style-prop-object.md) | Enforce style prop value being an object |
|                    |          | [`react/void-dom-elements-no-children`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/void-dom-elements-no-children.md) | Prevent void DOM elements (e.g. `<img />`, `<br />`) from receiving children |

#### JSX-specific rules

|                    |          | Name                                    | Description |
| ------------------ | -------- | --------------------------------------- | ----------- |
|                    |          | [`coffee/jsx-boolean-value`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-boolean-value.md) | Enforce boolean attributes notation in JSX <br> :warning: Unlike the eslint-plugin-react rule, the CoffeeScript version is not fixable |
|                    |          | [`react/jsx-child-element-spacing`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-child-element-spacing.md) | Enforce or disallow spaces inside of curly braces in JSX attributes and expressions. |
|                    | :wrench: | [`coffee/jsx-closing-bracket-location`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-closing-bracket-location.md) | Validate closing bracket location in JSX |
|                    | :wrench: | [`react/jsx-closing-tag-location`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-closing-tag-location.md) | Validate closing tag location in JSX |
|                    |          | [`coffee/jsx-curly-newline`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-curly-newline.md) | Enforce or disallow newlines inside of curly braces in JSX attributes and expressions <br> :warning: Unlike the eslint-plugin-react rule, the CoffeeScript version is not fixable |
|                    | :wrench: | [`react/jsx-curly-spacing`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-curly-spacing.md) | Enforce or disallow spaces inside of curly braces in JSX attributes and expressions |
|                    | :wrench: | [`react/jsx-equals-spacing`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-equals-spacing.md) | Enforce or disallow spaces around equal signs in JSX attributes |
|                    |          | [`react/jsx-filename-extension`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-filename-extension.md) | Restrict file extensions that may contain JSX |
|                    |          | [`coffee/jsx-first-prop-new-line`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-first-prop-new-line.md) | Enforce position of the first prop in JSX <br> :warning: Unlike the eslint-plugin-react rule, the CoffeeScript version is not fixable |
|                    |          | [`coffee/jsx-handler-names`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-handler-names.md) | Enforce event handler naming conventions in JSX |
|                    | :wrench: | [`coffee/jsx-indent`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-indent.md) | Validate JSX indentation |
|                    | :wrench: | [`react/jsx-indent-props`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-indent-props.md) | Validate props indentation in JSX |
| :heavy_check_mark: |          | [`coffee/jsx-key`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-key.md) | Validate JSX has key prop when in array or iterator |
|                    |          | [`react/jsx-max-depth`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-max-depth.md) | Validate JSX maximum depth |
|                    |          | [`coffee/jsx-max-props-per-line`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-max-props-per-line.md) | Limit maximum of props on a single line in JSX <br> :warning: Unlike the eslint-plugin-react rule, the CoffeeScript version is not fixable |
|                    |          | [`coffee/jsx-no-bind`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-no-bind.md) | Prevent usage of `.bind()` and arrow functions in JSX props |
| :heavy_check_mark: |          | [`coffee/jsx-no-comment-textnodes`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-no-comment-textnodes.md) | Prevent comments from being inserted as text nodes |
| :heavy_check_mark: |          | [`react/jsx-no-duplicate-props`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-no-duplicate-props.md) | Prevent duplicate props in JSX |
|                    |          | [`react/jsx-no-literals`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-no-literals.md) | Prevent usage of unwrapped JSX strings |
| :heavy_check_mark: |          | [`react/jsx-no-target-blank`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-no-target-blank.md) | Prevent usage of unsafe `target='_blank'` |
| :heavy_check_mark: |          | [`react/jsx-no-undef`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-no-undef.md) | Disallow undeclared variables in JSX |
|                    |          | [`coffee/jsx-one-expression-per-line`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-one-expression-per-line.md) | Limit to one expression per line in JSX |
|                    | :wrench: | [`react/jsx-curly-brace-presence`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-curly-brace-presence.md) | Enforce curly braces or disallow unnecessary curly braces in JSX |
|                    | :wrench: | [`coffee/jsx-fragments`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-fragments.md) | Enforce shorthand or standard form for React fragments |
|                    |          | [`react/jsx-pascal-case`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-pascal-case.md) | Enforce PascalCase for user-defined JSX components |
|                    | :wrench: | [`react/jsx-props-no-multi-spaces`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-props-no-multi-spaces.md) | Disallow multiple spaces between inline JSX props |
|                    |          | [`react/jsx-props-no-spreading`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-props-no-spreading.md) | Disallow JSX props spreading |
|                    |          | [`coffee/jsx-sort-default-props`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-sort-default-props.md) | Enforce default props alphabetical sorting |
|                    | :wrench: | [`react/jsx-sort-props`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-sort-props.md) | Enforce props alphabetical sorting |
|                    | :wrench: | [`coffee/jsx-tag-spacing`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-tag-spacing.md) | Validate whitespace in and around the JSX opening and closing brackets |
| :heavy_check_mark: |          | [`react/jsx-uses-react`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-uses-react.md) | Prevent React to be incorrectly marked as unused |
| :heavy_check_mark: |          | [`react/jsx-uses-vars`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-uses-vars.md) | Prevent variables used in JSX to be incorrectly marked as unused |
|                    |          | [`coffee/jsx-wrap-multilines`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/jsx-wrap-multilines.md) | Prevent missing parentheses around multilines JSX <br> :warning: Unlike the eslint-plugin-react rule, the CoffeeScript version is not fixable |

### eslint-plugin-import rules

#### Static analysis 

| Name                                    | Description |
| --------------------------------------- | ----------- |
| [`import/no-unresolved`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-unresolved.md) | Ensure imports point to a file/module that can be resolved |
| [`import/named`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/named.md) | Ensure named imports correspond to a named export in the remote file |
| [`import/default`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/default.md) | Ensure a default export is present, given a default import |
| [`coffee/namespace`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/namespace.md) | Ensure imported namespaces contain dereferenced properties as they are dereferenced |
| [`import/no-restricted-paths`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-restricted-paths.md) | Restrict which files can be imported in a given folder |
| [`import/no-absolute-path`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-absolute-path.md) | Forbid import of modules using absolute paths |
| [`import/no-dynamic-require`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-dynamic-require.md) | Forbid `require()` calls with expressions |
| [`import/no-internal-modules`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-internal-modules.md) | Prevent importing the submodules of other modules |
| [`import/no-webpack-loader-syntax`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-webpack-loader-syntax.md) | Forbid webpack loader syntax in imports |
| [`import/no-self-import`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-self-import.md) | Forbid a module from importing itself |
| [`import/no-cycle`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-cycle.md) | Forbid a module from importing a module with a dependency path back to itself |
| [`import/no-useless-path-segments`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-useless-path-segments.md) | Prevent unnecessary path segments in import and require statements |
| [`import/no-relative-parent-imports`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-relative-parent-imports.md) | Forbid importing modules from parent directories |
| [`coffee/no-unused-modules`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-unused-modules.md) | Forbid modules without any export, and exports not imported by any modules |

#### Helpful warnings

| Name                                    | Description |
| --------------------------------------- | ----------- |
| [`coffee/export`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/export.md) | Report any invalid exports, i.e. re-export of the same name |
| [`import/no-named-as-default`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-named-as-default.md) | Report use of exported name as identifier of default export |
| [`coffee/no-named-as-default-member`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-named-as-default-member.md) | Report use of exported name as property of default export |
| [`coffee/no-deprecated--import`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-deprecated.md) | Report imported names marked with `@deprecated` documentation tag |
| [`import/no-extraneous-dependencies`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-extraneous-dependencies.md) | Forbid the use of extraneous packages |

#### Module systems

| Name                                    | Description |
| --------------------------------------- | ----------- |
| [`coffee/no-commonjs`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-commonjs.md) | Report CommonJS `require` calls and `module.exports` or `exports.*`. |
| [`import/no-amd`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-amd.md) | Report AMD `require` and `define` calls. |
| [`import/no-nodejs-modules`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-nodejs-modules.md) | No Node.js builtin modules. |

#### Style guide

|          | Name                                    | Description |
| -------- | --------------------------------------- | ----------- |
| :wrench: | [`import/first`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/first.md) | Ensure all imports appear before other statements |
|          | [`import/exports-last`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/exports-last.md) | Ensure all exports appear after other statements |
| :wrench: | [`import/no-duplicates`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-duplicates.md) | Report repeated import of the same module in multiple places |
|          | [`import/no-namespace`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-namespace.md) | Forbid namespace (a.k.a. "wildcard" `*`) imports <br> :warning: Unlike the eslint-plugin-import rule, the CoffeeScript version is not fixable |
|          | [`import/extensions`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/extensions.md) | Ensure consistent use of file extension within the import path |
| :wrench: | [`coffee/order`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/order.md) | Enforce a convention in module import order |
| :wrench: | [`import/newline-after-import`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/newline-after-import.md) | Enforce a newline after import statements |
|          | [`import/prefer-default-export`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/prefer-default-export.md) | Prefer a default export if module exports a single name |
|          | [`import/max-dependencies`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/max-dependencies.md) | Limit the maximum number of dependencies a module can have |
|          | [`import/no-unassigned-import`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-unassigned-import.md) | Forbid unassigned imports |
|          | [`import/no-named-default`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-named-default.md) | Forbid named default exports |
|          | [`coffee/no-default-export`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-default-export.md) | Forbid default exports |
|          | [`coffee/no-named-export`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-named-export.md) | Forbid named exports |
|          | [`coffee/no-anonymous-default-export`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-anonymous-default-export.md) | Forbid anonymous values as default exports |
|          | [`import/group-exports`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/group-exports.md) | Prefer named exports to be grouped together in a single export declaration |
|          | [`coffee/dynamic-import-chunkname`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/dynamic-import-chunkname.md) | Enforce a leading comment with the webpackChunkName for dynamic imports |

### eslint-plugin-react-native rules

| Name                                    | Description |
| --------------------------------------- | ----------- |
| [`coffee/no-unused-styles`](https://github.com/Intellicode/eslint-plugin-react-native/blob/master/docs/rules/no-unused-styles.md) | Detect `StyleSheet` rules which are not used in your React components |
| [`coffee/split-platform-components`](https://github.com/Intellicode/eslint-plugin-react-native/blob/master/docs/rules/split-platform-components.md) | Enforce using platform specific filenames when necessary |
| [`react-native/no-inline-styles`](https://github.com/Intellicode/eslint-plugin-react-native/blob/master/docs/rules/no-inline-styles.md) | Detect JSX components with inline styles that contain literal values |
| [`coffee/no-color-literals`](https://github.com/Intellicode/eslint-plugin-react-native/blob/master/docs/rules/no-color-literals.md) | Detect `StyleSheet` rules and inline styles containing color literals instead of variables |

### eslint-plugin-jsx-a11y rules

| Name                                    | Description |
| --------------------------------------- | ----------- |
| [`jsx-a11y/accessible-emoji`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/accessible-emoji.md) | Enforce emojis are wrapped in `<span>` and provide screenreader access |
| [`jsx-a11y/alt-text`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/alt-text.md) | Enforce all elements that require alternative text have meaningful information to relay back to end user |
| [`jsx-a11y/anchor-has-content`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/anchor-has-content.md) | Enforce all anchors to contain accessible content |
| [`jsx-a11y/anchor-is-valid`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/anchor-is-valid.md) | Enforce all anchors are valid, navigable elements |
| [`jsx-a11y/aria-activedescendant-has-tabindex`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/aria-activedescendant-has-tabindex.md) | Enforce elements with aria-activedescendant are tabbable |
| [`jsx-a11y/aria-props`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/aria-props.md) | Enforce all `aria-*` props are valid |
| [`jsx-a11y/aria-proptypes`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/aria-proptypes.md) | Enforce ARIA state and property values are valid |
| [`jsx-a11y/aria-role`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/aria-role.md) | Enforce that elements with ARIA roles must use a valid, non-abstract ARIA role |
| [`jsx-a11y/aria-unsupported-elements`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/aria-unsupported-elements.md) | Enforce that elements that do not support ARIA roles, states, and properties do not have those attributes |
| [`jsx-a11y/click-events-have-key-events`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/click-events-have-key-events.md) | Enforce a clickable non-interactive element has at least one keyboard event listener |
| [`jsx-a11y/heading-has-content`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/heading-has-content.md) | Enforce heading (`h1`, `h2`, etc) elements contain accessible content |
| [`jsx-a11y/html-has-lang`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/html-has-lang.md) | Enforce `<html>` element has `lang` prop |
| [`jsx-a11y/iframe-has-title`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/iframe-has-title.md) | Enforce iframe elements have a title attribute |
| [`jsx-a11y/img-redundant-alt`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/img-redundant-alt.md) | Enforce `<img>` alt prop does not contain the word "image", "picture", or "photo" |
| [`jsx-a11y/interactive-supports-focus`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/interactive-supports-focus.md) | Enforce that elements with interactive handlers like `onClick` must be focusable |
| [`jsx-a11y/label-has-associated-control`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/label-has-associated-control.md) | Enforce that a label tag has a text label and an associated control |
| [`jsx-a11y/lang`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/lang.md) | Enforce lang attribute has a valid value |
| [`jsx-a11y/mouse-events-have-key-events`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/mouse-events-have-key-events.md) | Enforce that `onMouseOver`/`onMouseOut` are accompanied by `onFocus`/`onBlur` for keyboard-only users |
| [`jsx-a11y/no-autofocus`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/no-autofocus.md) | Enforce autoFocus prop is not used |
| [`jsx-a11y/no-distracting-elements`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/no-distracting-elements.md) | Enforce distracting elements are not used |
| [`jsx-a11y/no-interactive-element-to-noninteractive-role`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/no-interactive-element-to-noninteractive-role.md) | Interactive elements should not be assigned non-interactive roles |
| [`jsx-a11y/no-noninteractive-element-interactions`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/no-noninteractive-element-interactions.md) | Non-interactive elements should not be assigned mouse or keyboard event listeners |
| [`jsx-a11y/no-noninteractive-element-to-interactive-role`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/no-noninteractive-element-to-interactive-role.md) | Non-interactive elements should not be assigned interactive roles |
| [`jsx-a11y/no-noninteractive-tabindex`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/no-noninteractive-tabindex.md) | `tabIndex` should only be declared on interactive elements |
| [`jsx-a11y/no-onchange`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/no-onchange.md) | Enforce usage of `onBlur` over `onChange` on select menus for accessibility |
| [`jsx-a11y/no-redundant-roles`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/no-redundant-roles.md) | Enforce explicit role property is not the same as implicit/default role property on element |
| [`jsx-a11y/no-static-element-interactions`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/no-static-element-interactions.md) | Enforce that non-interactive, visible elements (such as `<div>`) that have click handlers use the role attribute |
| [`jsx-a11y/role-has-required-aria-props`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/role-has-required-aria-props.md) | Enforce that elements with ARIA roles must have all required attributes for that role |
| [`jsx-a11y/role-supports-aria-props`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/role-supports-aria-props.md) | Enforce that elements with explicit or implicit roles defined contain only `aria-*` properties supported by that `role` |
| [`jsx-a11y/scope`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/scope.md) | Enforce `scope` prop is only used on `<th>` elements |
| [`jsx-a11y/tabindex-no-positive`](https://github.com/evcohen/eslint-plugin-jsx-a11y/blob/master/docs/rules/tabindex-no-positive.md) | Enforce `tabIndex` value is not greater than zero |

### Non-applicable ESLint-included rules

Some rules included with ESLint, `eslint-plugin-react` and `eslint-plugin-import` don't apply to CoffeeScript. These include:

- [`for-direction`](https://eslint.org/docs/rules/for-direction)
- [`getter-return`](https://eslint.org/docs/rules/getter-return)
- [`no-dupe-args`](https://eslint.org/docs/rules/no-dupe-args)
- [`no-extra-semi`](https://eslint.org/docs/rules/no-extra-semi)
- [`no-func-assign`](https://eslint.org/docs/rules/no-func-assign)
- [`no-unexpected-multiline`](https://eslint.org/docs/rules/no-unexpected-multiline)
- [`array-callback-return`](https://eslint.org/docs/rules/array-callback-return)
- [`consistent-return`](https://eslint.org/docs/rules/consistent-return)
- [`curly`](https://eslint.org/docs/rules/curly)
- [`eqeqeq`](https://eslint.org/docs/rules/eqeqeq)
- [`no-case-declarations`](https://eslint.org/docs/rules/no-case-declarations)
- [`no-eq-null`](https://eslint.org/docs/rules/no-eq-null)
- [`no-extra-label`](https://eslint.org/docs/rules/no-extra-label)
- [`no-fallthrough`](https://eslint.org/docs/rules/no-fallthrough)
- [`no-implicit-globals`](https://eslint.org/docs/rules/no-implicit-globals)
- [`no-labels`](https://eslint.org/docs/rules/no-labels)
- [`no-lone-blocks`](https://eslint.org/docs/rules/no-lone-blocks)
- [`no-octal`](https://eslint.org/docs/rules/no-octal)
- [`no-octal-escape`](https://eslint.org/docs/rules/no-octal-escape)
- [`no-redeclare`](https://eslint.org/docs/rules/no-redeclare)
- [`no-unused-labels`](https://eslint.org/docs/rules/no-unused-labels)
- [`no-void`](https://eslint.org/docs/rules/no-void)
- [`no-with`](https://eslint.org/docs/rules/no-with)
- [`require-await`](https://eslint.org/docs/rules/require-await)
- [`wrap-iife`](https://eslint.org/docs/rules/wrap-iife)
- [`init-declarations`](https://eslint.org/docs/rules/init-declarations)
- [`no-label-var`](https://eslint.org/docs/rules/no-label-var)
- [`no-shadow-restricted-names`](https://eslint.org/docs/rules/no-shadow-restricted-names)
- [`no-undef-init`](https://eslint.org/docs/rules/no-undef-init)
- [`no-undefined`](https://eslint.org/docs/rules/no-undefined)
- [`no-mixed-requires`](https://eslint.org/docs/rules/no-mixed-requires)
- [`block-spacing`](https://eslint.org/docs/rules/block-spacing)
- [`brace-style`](https://eslint.org/docs/rules/brace-style)
- [`func-call-spacing`](https://eslint.org/docs/rules/func-call-spacing)
- [`func-name-matching`](https://eslint.org/docs/rules/func-name-matching)
- [`func-names`](https://eslint.org/docs/rules/func-names)
- [`func-style`](https://eslint.org/docs/rules/func-style)
- [`max-statements-per-line`](https://eslint.org/docs/rules/max-statements-per-line)
- [`no-mixed-spaces-and-tabs`](https://eslint.org/docs/rules/no-mixed-spaces-and-tabs)
- [`no-nested-ternary`](https://eslint.org/docs/rules/no-nested-ternary)
- [`no-ternary`](https://eslint.org/docs/rules/no-ternary)
- [`nonblock-statement-body-position`](https://eslint.org/docs/rules/nonblock-statement-body-position)
- [`object-curly-newline`](https://eslint.org/docs/rules/object-curly-newline)
- [`one-var`](https://eslint.org/docs/rules/one-var)
- [`one-var-declaration-per-line`](https://eslint.org/docs/rules/one-var-declaration-per-line)
- [`semi`](https://eslint.org/docs/rules/semi)
- [`semi-spacing`](https://eslint.org/docs/rules/semi-spacing)
- [`semi-style`](https://eslint.org/docs/rules/semi-style)
- [`sort-vars`](https://eslint.org/docs/rules/sort-vars)
- [`space-before-blocks`](https://eslint.org/docs/rules/space-before-blocks)
- [`space-before-function-paren`](https://eslint.org/docs/rules/space-before-function-paren)
- [`switch-colon-spacing`](https://eslint.org/docs/rules/switch-colon-spacing)
- [`template-tag-spacing`](https://eslint.org/docs/rules/template-tag-spacing)
- [`arrow-body-style`](https://eslint.org/docs/rules/arrow-body-style)
- [`arrow-parens`](https://eslint.org/docs/rules/arrow-parens)
- [`generator-star-spacing`](https://eslint.org/docs/rules/generator-star-spacing)
- [`no-confusing-arrow`](https://eslint.org/docs/rules/no-confusing-arrow)
- [`no-const-assign`](https://eslint.org/docs/rules/no-const-assign)
- [`no-var`](https://eslint.org/docs/rules/no-var)
- [`prefer-arrow-callback`](https://eslint.org/docs/rules/prefer-arrow-callback)
- [`prefer-const`](https://eslint.org/docs/rules/prefer-const)
- [`require-yield`](https://eslint.org/docs/rules/require-yield)
- [`yield-star-spacing`](https://eslint.org/docs/rules/yield-star-spacing)
- [`no-multi-str`](https://eslint.org/docs/rules/no-multi-str)
- [`react/require-render-return`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/require-render-return.md)
- [`react/state-in-constructor`](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/state-in-constructor.md)
- [`import/no-mutable-exports`](https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-mutable-exports.md)

## Supported CoffeeScript version

We will always endeavor to support the latest stable version of CoffeeScript.

**Currently to run this plugin you need to use the latest Coffeescript `ast` branch: github:jashkenas/coffeescript#05d45e9b.**

## Supported ESLint version

**The version range of ESLint currently supported by this plugin is `>=6.0.0`.**

## Supported versions of eslint-plugin-react, eslint-plugin-import, eslint-plugin-react-native, eslint-plugin-jsx-a11y

**The version range of `eslint-plugin-react` currently supported by this plugin is `>=7.17.0`.**

**The version range of `eslint-plugin-import` currently supported by this plugin is `>=2.19.0`.**

**The version range of `eslint-plugin-react-native` currently supported by this plugin is `>=3.8.0`.**

**The version range of `eslint-plugin-jsx-a11y` currently supported by this plugin is `>=6.2.3`.**

## Migrating from CoffeeLint

Here is a mapping from CoffeeLint rules to their corresponding ESLint rules:

| CoffeeLint rule | ESLint rule |
| --------------- | ----------- |
| `arrow_spacing` | [`coffee/arrow-spacing`](https://eslint.org/docs/rules/arrow-spacing) |
| `braces_spacing` | [`coffee/object-curly-spacing`](https://eslint.org/docs/rules/object-curly-spacing) |
| `camel_case_classes` | [`coffee/camelcase`](https://eslint.org/docs/rules/camelcase) + [`coffee/capitalized-class-names`](./docs/rules/capitalized-class-names.md) |
| `coffeescript_error` | If the CoffeeScript compiler fails to parse/produce AST for a source file, ESLint will report it as a parsing error. |
| `colon_assignment_spacing` | [`key-spacing`](https://eslint.org/docs/rules/key-spacing) |
| `cyclomatic_complexity` | [`coffee/complexity`](https://eslint.org/docs/rules/complexity) |
| `duplicate_key` | [`no-dupe-keys`](https://eslint.org/docs/rules/no-dupe-keys) |
| `empty_constructor_needs_parens` | [`new-parens`](https://eslint.org/docs/rules/new-parens) |
| `ensure_comprehensions` | [`coffee/postfix-comprehension-assign-parens`](./docs/rules/postfix-comprehension-assign-parens.md) <br> (this behavior is also covered if you're using [Prettier](https://github.com/helixbass/prettier-plugin-coffeescript)) |
| `eol_last` | [`eol-last`](https://eslint.org/docs/rules/eol-last) |
| `indentation` | Not yet implemented. <br> (this behavior is also covered if you're using [Prettier](https://github.com/helixbass/prettier-plugin-coffeescript)) |
| `line_endings` | [`linebreak-style`](https://eslint.org/docs/rules/linebreak-style) |
| `max_line_length` | [`coffee/max-len`](https://eslint.org/docs/rules/max-len) |
| `missing_fat_arrows` | [`coffee/no-invalid-this`](https://eslint.org/docs/rules/no-invalid-this) |
| `newlines_after_classes` | Not yet implemented. <br> (this behavior is also partially covered if you're using [Prettier](https://github.com/helixbass/prettier-plugin-coffeescript)) |
| `no_backticks` | [`coffee/no-backticks`](./docs/rules/no-backticks.md) |
| `no_debugger` | [`no-debugger`](https://eslint.org/docs/rules/no-debugger) |
| `no_empty_functions` | [`coffee/no-empty-function`](https://eslint.org/docs/rules/no-empty-function) |
| `no_empty_param_list` | [`coffee/empty-func-parens`](https://eslint.org/docs/rules/no-empty-function) |
| `no_implicit_braces` | [`coffee/implicit-object`](./docs/rules/implicit-object.md) |
| `no_implicit_parens` | [`coffee/implicit-call`](./docs/rules/implicit-call.md) |
| `no_interpolation_in_single_quotes` | [`coffee/no-template-curly-in-string`](https://eslint.org/docs/rules/no-template-curly-in-string) |
| `no_nested_string_interpolation` | [`coffee/no-nested-interpolation`](./docs/rules/no-nested-interpolation.md) |
| `no_plusplus` | [`no-plusplus`](https://eslint.org/docs/rules/no-plusplus) |
| `no_private_function_fat_arrows` | [`coffee/no-private-function-fat-arrows`](./docs/rules/no-private-function-fat-arrows.md) |
| `no_stand_alone_at` | [`coffee/shorthand-this`](./docs/rules/shorthand-this.md) |
| `no_tabs` | [`no-tabs`](https://eslint.org/docs/rules/no-tabs) |
| `no_this` | [`coffee/shorthand-this`](./docs/rules/shorthand-this.md) |
| `no_throwing_strings` | [`no-throw-literal`](https://eslint.org/docs/rules/no-throw-literal) |
| `no_trailing_semicolons` | Not yet implemented. <br> (this behavior is also covered if you're using [Prettier](https://github.com/helixbass/prettier-plugin-coffeescript)) |
| `no_trailing_whitespace` | [`no-trailing-spaces`](https://eslint.org/docs/rules/no-trailing-spaces) |
| `no_unnecessary_double_quotes` | [`coffee/no-unnecessary-double-quotes`](./docs/rules/no-unnecessary-double-quotes.md) |
| `no_unnecessary_fat_arrows` | [`coffee/no-unnecessary-fat-arrow`](./docs/rules/no-unnecessary-fat-arrow.md) |
| `non_empty_constructor_needs_parens` | [`coffee/implicit-call`](./docs/rules/implicit-call.md) |
| `prefer_english_operator` | [`coffee/english-operators`](./docs/rules/english-operators.md) |
| `space_operators` | [`coffee/space-infix-ops`](https://eslint.org/docs/rules/space-infix-ops) + [`coffee/space-unary-ops`](https://eslint.org/docs/rules/space-unary-ops) |
| `spacing_after_comma` | [`comma-spacing`](https://eslint.org/docs/rules/comma-spacing) |
| `transform_messes_up_line_numbers` | Doesn't apply. |

If you haven't used ESLint before, you'll just need an `.eslintrc` config file in your project root - the [Installation](#installation) and [Usage](#usage) sections above cover how to get started. For further information, you may want to look at the [official ESLint guide](https://eslint.org/docs/user-guide/getting-started).

## How can I help?

See an issue? [Report it](https://github.com/helixbass/eslint-plugin-coffee/issues)!

If you have the time and inclination, you can even take it a step further and submit a PR to improve the project.

## License

`eslint-plugin-coffee` is licensed under the MIT License.
